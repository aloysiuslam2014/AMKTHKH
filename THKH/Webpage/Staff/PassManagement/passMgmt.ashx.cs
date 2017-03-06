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
using THKH.Classes.DAO;
using THKH.Classes.Entity;

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
                var passState = context.Request.Unvalidated.Form["passState"] ;
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
            GenericProcedureDAO procedureCall = new GenericProcedureDAO("GET_PASS_FORMAT", false, true, true);
            DataTable dataTable = new DataTable();
            dynamic stateOfPass = new ExpandoObject();
            procedureCall.addParameter("@responseMessage", SqlDbType.Int);
            try
            {
                ProcedureResponse result = procedureCall.runProcedure();
                dataTable = result.getDataTable();
                stateOfPass.Result = "Success";
            }
            catch (Exception ex)
            {
                stateOfPass.Result = "Failure";
                stateOfPass.Msg = ex.Message;
                return stateOfPass;
            }
           
            String placeName = "";
            for (var i = 0; i < dataTable.Rows.Count; i++)
            {
                placeName = dataTable.Rows[i]["passFormat"].ToString();
            }
            stateOfPass.Msg = Newtonsoft.Json.JsonConvert.DeserializeObject<dynamic>(placeName);//Json object contains: divState(div object holding pass contents) and positions(position offsets of elements within div) in json format

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
            GenericProcedureDAO procedureCall = new GenericProcedureDAO("SET_PASS_FORMAT", true, true, false);
            dynamic stateOfPass = new ExpandoObject();
            stateOfPass.divState = state;
            stateOfPass.positions = statePositions;

            string jsonState = Newtonsoft.Json.JsonConvert.SerializeObject(stateOfPass);
            procedureCall.addParameter("@responseMessage", SqlDbType.Int);
            procedureCall.addParameterWithValue("@pPass_Format", jsonState);
            try
            {
                procedureCall.runProcedure();

                successString = "Success";
            }
            catch (Exception ex)
            {
                successString = "Error occured. Sql error";
                
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