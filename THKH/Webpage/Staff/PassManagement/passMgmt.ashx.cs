using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using GenCode128;
using System.Drawing;
using System.IO;
using System.Dynamic;
using System.Text;

namespace THKH.Webpage.Staff.PassManagement
{
    /// <summary>
    /// Summary description for passMgmt
    /// </summary>
    public class passMgmt : IHttpHandler
    {

        public void ProcessRequest(HttpContext context)
        {
            string returnString = "";
            var requestType = context.Request.Form["requestType"];
            if (requestType.Equals("generateBar"))
            {
                var textToEnc = context.Request.Form["textEnc"];
                returnString = generateBarcode(textToEnc);
            }
            context.Response.ContentType = "text/plain";
         
            context.Response.Write(returnString);
        }

        public string generateBarcode(string textToEncode)
        {
            string successString = "";
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