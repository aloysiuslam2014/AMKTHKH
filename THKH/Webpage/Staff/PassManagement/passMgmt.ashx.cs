using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using GenCode128;
using System.Drawing;
using System.IO;
using System.Dynamic;
using System.Text;
using System.Data.SqlClient;
using System.Data;
using System.Net;

namespace THKH.Webpage.Staff.PassManagement
{
    /// <summary>
    /// Summary description for passMgmt
    /// </summary>
    public class passMgmt : IHttpHandler
    {

        public void ProcessRequest(HttpContext context)
        {
            dynamic returnMe = new ExpandoObject();
            dynamic result = new ExpandoObject();


            string returnString = "";
            var requestType = context.Request.Form["requestType"];
            if (requestType.Equals("generateBar"))
            {
                var textToEnc = context.Request.Form["textEnc"];
                result = generateBarcode(textToEnc);
                returnMe.Result = result.Result;
                returnMe.Msg = result.data;
            }
            if (requestType.Equals("savePassState"))
            {
                var passState = WebUtility.HtmlEncode(context.Request.Unvalidated.Form["passState"]);
                var elementsPosition = context.Request.Form["positioning"];
                returnMe.Result = setPassState(passState,elementsPosition);

          
            }
            if (requestType.Equals("getPassState"))
            {
                result = getPassState();
                returnMe.Result = result.Result;
                returnMe.Msg = result.Msg;//Json object contains: divState(div object holding pass contents) and positions(position offsets of elements within div)
                //
            }
            context.Response.ContentType = "text/plain";
           // String results = returnMe.Result;
            if(returnMe.Result.Equals("Success"))
            {
               
            }else
            {
                returnMe.Msg = returnMe.Result;
            }
            returnString = Newtonsoft.Json.JsonConvert.SerializeObject(returnMe);
            context.Response.Write(returnString);
        }

        private dynamic getPassState()
        {
             
            DataTable dataTable = new DataTable();
            dynamic stateOfPass = new ExpandoObject();
            
            string jsonState = Newtonsoft.Json.JsonConvert.SerializeObject(stateOfPass);

            SqlConnection cnn;

            cnn = new SqlConnection(System.Configuration.ConfigurationManager.ConnectionStrings["offlineConnection"].ConnectionString);
            SqlParameter respon = new SqlParameter("@responseMessage", SqlDbType.Int);
            respon.Direction = ParameterDirection.Output;
            try
            {
                SqlCommand command = new SqlCommand("[dbo].[GET_PASS_FORMAT]", cnn);
                command.CommandType = System.Data.CommandType.StoredProcedure;
                command.Parameters.Add(respon);
                cnn.Open();
                SqlDataAdapter da = new SqlDataAdapter();
                da.SelectCommand = command;
                da.Fill(dataTable);

                stateOfPass.Result = "Success";
            }
            catch (Exception ex)
            {
                stateOfPass.Result = "Failure";
                stateOfPass.Msg = ex.Message;
                return stateOfPass;

            }
            finally
            {
                cnn.Close();
            }
            String placeName = "";
            for (var i = 0; i < dataTable.Rows.Count; i++)
            {
                placeName = dataTable.Rows[i]["passFormat"].ToString();


            }

            stateOfPass.Msg = Newtonsoft.Json.JsonConvert.DeserializeObject<dynamic>(placeName);//Json object contains: divState(div object holding pass contents) and positions(position offsets of elements within div) in json format
            if(stateOfPass.Msg != null)
            stateOfPass.Msg.divState = WebUtility.HtmlDecode(""+stateOfPass.Msg.divState);
            return stateOfPass;
        }

        public dynamic generateBarcode(string textToEncode)
        {
            string successString = "";
            dynamic jsonResult = new ExpandoObject();
            dynamic jsonReturn = new ExpandoObject();
            
            try
            {
                Image myimg = Code128Rendering.MakeBarcodeImage(textToEncode,
                                          1, true);//https://www.codeproject.com/kb/gdi-plus/gencode128.aspx
                MemoryStream ms = new MemoryStream();
                myimg.Save(ms, System.Drawing.Imaging.ImageFormat.Png);
                jsonReturn.Result = "Success";
                byte[] imageData = ms.ToArray();
              //  jsonReturn.Msg = HexStringFromBytes(imageData);
                jsonReturn.Msg = imageData;

            }
            catch(Exception e)
            {
                jsonReturn.Result = "Failed";
                jsonReturn.Msg = "Failed To Generate the image. Library error.";
                 
            }
          
            successString = Newtonsoft.Json.JsonConvert.SerializeObject(jsonReturn);
            jsonResult.Result = jsonReturn.Result;
            jsonReturn.data = jsonReturn.Msg;
            return jsonReturn;
        }
      
        public string setPassState(string state,string statePositions)
        {
            string successString = "";

            dynamic stateOfPass = new ExpandoObject();
            stateOfPass.divState = state;
            stateOfPass.positions = statePositions;
            string jsonState = Newtonsoft.Json.JsonConvert.SerializeObject(stateOfPass);

            SqlConnection cnn;
            
            cnn = new SqlConnection(System.Configuration.ConfigurationManager.ConnectionStrings["offlineConnection"].ConnectionString);
            SqlParameter respon = new SqlParameter("@responseMessage", SqlDbType.Int);
            respon.Direction = ParameterDirection.Output;
            try
            {
                SqlCommand command = new SqlCommand("[dbo].[SET_PASS_FORMAT]", cnn);
                command.CommandType = System.Data.CommandType.StoredProcedure;
                command.Parameters.AddWithValue("@pPass_Format", jsonState);
                command.Parameters.Add(respon);
                cnn.Open();

                command.ExecuteNonQuery();
                successString = "Success";
            }
            catch (Exception ex)
            {
                successString = "Error occured. Sql error";
                
            }
            finally
            {
                cnn.Close();
            }
            return successString;
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