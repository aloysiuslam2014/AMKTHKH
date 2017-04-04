using System;
using GenCode128;
using System.Drawing;
using System.IO;
using System.Dynamic;
using System.Data;
using THKH.Classes.DAO;
using THKH.Classes.Entity;

namespace THKH.Classes.Controller
{
    public class PassManagementController
    {
        private GenericProcedureDAO procedureCall;
        private ProcedureResponse result;

        /// <summary>
        /// Gets the Pass current state
        /// </summary>
        /// <returns>returns dynamic object that holds the pass contents</returns>
        public dynamic getPassState()
        {
            DataTable dataTable = new DataTable();
            dynamic stateOfPass = new ExpandoObject();
            procedureCall = new GenericProcedureDAO("GET_PASS_FORMAT", false, true, true);
            procedureCall.addParameter("@responseMessage", SqlDbType.Int);
            try
            {
                result = procedureCall.runProcedure();
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

        /// <summary>
        /// Generates barcode image and returns it in base64 format within a dynamic object
        /// </summary>
        /// <param name="textToEncode">Self explanatory</param>
        /// <returns>Dynamic object that holds the barcode image</returns>
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
                jsonReturn.Msg = imageData;

            }
            catch (Exception e)
            {
                jsonReturn.Result = "Failed";
                jsonReturn.Msg = "Failed To Generate the image. Library error.";

            }

            successString = Newtonsoft.Json.JsonConvert.SerializeObject(jsonReturn);
            jsonResult.Result = jsonReturn.Result;
            jsonReturn.data = jsonReturn.Msg;
            return jsonReturn;
        }

        /// <summary>
        /// Gets the state of the pass and saves it to the db
        /// </summary>
        /// <param name="state">The state of the pass (html string)</param>
        /// <param name="statePositions">Old no longer in use but stil needs some input</param>
        /// <returns>Success or error</returns>
        public string setPassState(string state, string statePositions)
        {
            string successString = "";

            dynamic stateOfPass = new ExpandoObject();
            stateOfPass.divState = state;
            stateOfPass.positions = statePositions;
            string jsonState = Newtonsoft.Json.JsonConvert.SerializeObject(stateOfPass);

            procedureCall = new GenericProcedureDAO("SET_PASS_FORMAT", true, true, false);
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

    }
}