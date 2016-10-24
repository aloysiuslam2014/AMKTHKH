using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

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
            
        }

        protected void SubmitNewReg(object sender, EventArgs e)
        {

        }
    }
}