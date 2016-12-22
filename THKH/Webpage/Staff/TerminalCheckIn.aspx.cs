using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace THKH.Webpage.Staff
{
    public partial class TerminalCheckIn : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {

            

            DataTable dataTable = new DataTable();
            SqlConnection cnn;
            //connectionString = "Data Source=ALOYSIUS;Initial Catalog=thkhdb;Integrated Security=SSPI;";
            //connectionString = "Data Source=SHAH\\SQLEXPRESS;Initial Catalog=thkhdb;Integrated Security=SSPI;";
            cnn = new SqlConnection(System.Configuration.ConfigurationManager.ConnectionStrings["offlineConnection"].ConnectionString);
            try
            {
                SqlCommand command = new SqlCommand("[dbo].[GET_INACTIVE_TERMINAL]", cnn);
                command.CommandType = System.Data.CommandType.StoredProcedure;
                //command.Parameters.AddWithValue("@pNric", txtUserName.Value.ToString());
                cnn.Open();
               
                SqlDataAdapter da = new SqlDataAdapter();
                da.SelectCommand = command;
                da.Fill(dataTable);
                //rows = command.ExecuteNonQuery();
               
               
                cnn.Close();
                
            }
            catch (Exception ex)
            {
                
            }
           
          
            for(var i =0; i < dataTable.Rows.Count; i++) 
            {
                String placeName = dataTable.Rows[i]["tName"].ToString();
                String id = dataTable.Rows[i]["terminalID"].ToString();
                System.Web.UI.HtmlControls.HtmlGenericControl createDiv =
                      new System.Web.UI.HtmlControls.HtmlGenericControl("DIV");
                
                Label name = new Label();
                name.Attributes.Add("class", "textOpt");
                name.Text = placeName;
                System.Web.UI.HtmlControls.HtmlGenericControl activate =
                      new System.Web.UI.HtmlControls.HtmlGenericControl("input");
              
                activate.Attributes.Add("type", "button");
                activate.Attributes.Add("value", "Activate");

                createDiv.ID = placeName + ":" + id; // activate name is the terminal id
                createDiv.Controls.Add(name);
                createDiv.Attributes.Add("class", "form-control btn divTerminal");
                createDiv.Attributes.Add("onclick", "activateMe(this);false;");
                createDiv.Attributes.Add("style", "height: 47px;");
                terminalsAvail.Controls.Add(createDiv);
            }
        }

        protected void returnToLogin(object sender, EventArgs e)
        {
            Response.Redirect("./Login.aspx");
        }
    }
}