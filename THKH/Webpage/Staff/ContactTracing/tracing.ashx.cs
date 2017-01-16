using System;
using System.Collections;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Dynamic;
using System.Linq;
using System.Web;

namespace THKH.Webpage.Staff.ContactTracing
{
    /// <summary>
    /// Summary description for tracing
    /// </summary>
    public class tracing : IHttpHandler
    {

        public void ProcessRequest(HttpContext context)
        {
            context.Response.ContentType = "text/plain";
            var action = context.Request.Form["action"];
            var returnoutput="";
            if (action.Equals("getValidTerminals"))
            {
                var query = context.Request.Form["queries"];
                returnoutput =  getValidTerminals(query);
            }
            if (action.Equals("traceByReg"))
            {
                var query = context.Request.Form["queries"];
                returnoutput = traceByReg(query);
            }
            if (action.Equals("unifiedTrace"))
            {
                var query = context.Request.Form["queries"];
                returnoutput = unifiedTrace(query);
            }
            context.Response.Write(returnoutput);
        }
        public String unifiedTrace(String query) {
            String result = "";

            String[] queryParts = query.Split('~');
            DateTime uq_startdate = DateTime.Parse(queryParts[0]);
            DateTime uq_enddate = DateTime.Parse(queryParts[1]);
            String uq_bednos = queryParts[2];
            String[] uq_bedno_arr = uq_bednos.Split(',');

            String[] processed_uq_bedno_arr = processBedNos(uq_bedno_arr);

            ArrayList byRegBed_response_visitors = new ArrayList();
            ArrayList byScanBed_response_visitors = new ArrayList();
            
            dynamic json = new ExpandoObject();
            dynamic innerItem = new ExpandoObject();
            ArrayList byRegBedArrayList = new ArrayList();

            for (var i = 0; i < processed_uq_bedno_arr.Length; i++)
            {
                byRegBed_response_visitors.Add(traceByRegBed(uq_startdate, uq_enddate, processed_uq_bedno_arr[i]));
            }

            for (var i = 0; i < processed_uq_bedno_arr.Length; i++)
            {
                byScanBed_response_visitors.Add(traceByScanBed(uq_startdate, uq_enddate, processed_uq_bedno_arr[i]));
            }

            //handle the annoying arraylists of json strings, each of which is a result from calling a procedure.
            //find the intersects, and derive the other 2 categories.
            //construct and return Expando Object with only the parameters required for the display table.

            return result;
        }

        public String traceByScanBed(DateTime startdatetime, DateTime enddatetime, String bedno)
        {
            String result = "";

            dynamic json = new ExpandoObject();

            SqlConnection cnn;
            cnn = new SqlConnection(System.Configuration.ConfigurationManager.ConnectionStrings["offlineConnection"].ConnectionString);
            SqlParameter respon = new SqlParameter("@responseMessage", System.Data.SqlDbType.Int);
            respon.Direction = ParameterDirection.Output;
            SqlParameter visitors = new SqlParameter("@Visitors", System.Data.SqlDbType.NVarChar);
            visitors.Direction = ParameterDirection.Output;
            visitors.Size = 4000;

            try
            {
                SqlCommand command = new SqlCommand("[dbo].[TRACE_BY_SCAN_BED]", cnn);
                command.CommandType = System.Data.CommandType.StoredProcedure;
                command.Parameters.AddWithValue("@pStart_Date", startdatetime);
                command.Parameters.AddWithValue("@pEnd_Date", enddatetime);
                command.Parameters.AddWithValue("@pBed_No", bedno);

                command.Parameters.Add(respon);
                command.Parameters.Add(visitors);
                cnn.Open();
                command.ExecuteNonQuery();

            }
            catch (Exception ex)
            {
                json.Result = "Failed";
                json.Msg = ex.Message;
            }

            String byScanBed_response_visitors = visitors.Value.ToString(); // json array of json objects, each of which is a visitor

            json.Result = "Success";
            json.Msg = byScanBed_response_visitors;

            result = Newtonsoft.Json.JsonConvert.SerializeObject(json);

            return result;
        }

        public String traceByRegBed(DateTime startdatetime, DateTime enddatetime, String bedno) {
            String result = "";

            dynamic json = new ExpandoObject();

            SqlConnection cnn;
            cnn = new SqlConnection(System.Configuration.ConfigurationManager.ConnectionStrings["offlineConnection"].ConnectionString);
            SqlParameter respon = new SqlParameter("@responseMessage", System.Data.SqlDbType.Int);
            respon.Direction = ParameterDirection.Output;
            SqlParameter visitors = new SqlParameter("@Visitors", System.Data.SqlDbType.NVarChar);
            visitors.Direction = ParameterDirection.Output;
            visitors.Size = 4000;

            try
            {
                SqlCommand command = new SqlCommand("[dbo].[TRACE_BY_REG_BED]", cnn);
                command.CommandType = System.Data.CommandType.StoredProcedure;
                command.Parameters.AddWithValue("@pStart_Date", startdatetime);
                command.Parameters.AddWithValue("@pEnd_Date", enddatetime);
                command.Parameters.AddWithValue("@pBed_No", bedno);

                command.Parameters.Add(respon);
                command.Parameters.Add(visitors);
                cnn.Open();
                command.ExecuteNonQuery();

            }
            catch (Exception ex)
            {
                json.Result = "Failed";
                json.Msg = ex.Message;
            }

            String byRegBed_response_visitors = visitors.Value.ToString(); // json array of json objects, each of which is a visitor

            json.Result = "Success";
            json.Msg = byRegBed_response_visitors;

            result = Newtonsoft.Json.JsonConvert.SerializeObject(json);
            return result;
        }

        public String[] processBedNos(String[] bedno_arr) {
            ArrayList result = new ArrayList();

            for (var i = 0; i < bedno_arr.Length; i++) {
                String thisBedNoToken = bedno_arr[i];

                if (thisBedNoToken.Contains("-"))
                {
                    String[] bednoRange = thisBedNoToken.Split('-');
                    Int32 rangeStart = Int32.Parse(bednoRange[0]);
                    Int32 rangeEnd = Int32.Parse(bednoRange[1]);
                    int rangeCount = rangeEnd - rangeStart + 1;

                    int[] processed_bedrange = Enumerable.Range(rangeStart, rangeCount).ToArray();

                    foreach (int bedno in processed_bedrange) {
                        result.Add(bedno.ToString());
                    }
                }
                else
                {
                    result.Add(thisBedNoToken);
                }
            }

            return (String[])result.ToArray();
        }

        public String traceByReg(String query) {
            String result = "";
            String[] queryParts = query.Split('~');
            DateTime ri_dateStart = DateTime.Parse(queryParts[0]);
            DateTime ri_dateEnd = DateTime.Parse(queryParts[1]);
            String bedNo = queryParts[2];

            dynamic json = new ExpandoObject();
            dynamic innerItem = new ExpandoObject();
            ArrayList byBedNoResults = new ArrayList();

            SqlConnection cnn;
            cnn = new SqlConnection(System.Configuration.ConfigurationManager.ConnectionStrings["offlineConnection"].ConnectionString);
            SqlParameter respon = new SqlParameter("@responseMessage", System.Data.SqlDbType.Int);
            respon.Direction = ParameterDirection.Output;
            SqlParameter visitors = new SqlParameter("@Visitors", System.Data.SqlDbType.NVarChar);
            visitors.Direction = ParameterDirection.Output;
            visitors.Size = 4000;
            SqlParameter visitorDetails = new SqlParameter("@Visitor_Details", System.Data.SqlDbType.NVarChar);
            visitorDetails.Direction = ParameterDirection.Output;
            visitorDetails.Size = 4000;
            try
            {
                SqlCommand command = new SqlCommand("[dbo].[GET_TRACE_BEDNO]", cnn);
                command.CommandType = System.Data.CommandType.StoredProcedure;
                command.Parameters.AddWithValue("@pStart_Date", ri_dateStart);
                command.Parameters.AddWithValue("@pEnd_Date", ri_dateEnd);
                command.Parameters.AddWithValue("@pBed_No", bedNo);

                command.Parameters.Add(respon);
                command.Parameters.Add(visitors);
                command.Parameters.Add(visitorDetails);
                cnn.Open();
                command.ExecuteNonQuery();

            }
            catch (Exception ex)
            {
                json.Result = "Failed";
                json.Msg = ex.Message;
            }

            String response_visitors = visitors.Value.ToString();
            String response_visitorDetails = visitorDetails.Value.ToString();
            innerItem.visitors = response_visitors;
            innerItem.visitorDetails = response_visitorDetails;
            byBedNoResults.Add(innerItem);

            json.Result = "Success";
            json.Msg = byBedNoResults;

            result = Newtonsoft.Json.JsonConvert.SerializeObject(json);

            return result;
        }

        public String getValidTerminals(String query)
        {
            DataTable dataTable = new DataTable();
            string result = "";
            string startString = query.Split('~').First();
            string endString = query.Split('~').Last();
            DateTime startDate = DateTime.Parse(startString);
            DateTime endDate = DateTime.Parse(endString);
            dynamic json = new ExpandoObject();
            dynamic innerItem = new ExpandoObject();
            ArrayList terminalDetails = new ArrayList();
            SqlConnection cnn;
            //connectionString = "Data Source=SHAH\\SQLEXPRESS;Initial Catalog=thkhdb;Integrated Security=SSPI;";
            cnn = new SqlConnection(System.Configuration.ConfigurationManager.ConnectionStrings["offlineConnection"].ConnectionString);

            SqlParameter respon = new SqlParameter("@responseMessage", System.Data.SqlDbType.Int);
            respon.Direction = ParameterDirection.Output;
            try
            {
                SqlCommand command = new SqlCommand("[dbo].[GET_TRACE_TERMINALS]", cnn);
                command.CommandType = System.Data.CommandType.StoredProcedure;
                command.Parameters.AddWithValue("@pStart_Date", startDate);
                command.Parameters.AddWithValue("@pEnd_Date", endDate);

                command.Parameters.Add(respon);
                cnn.Open();
                SqlDataAdapter da = new SqlDataAdapter();
                da.SelectCommand = command;
                da.Fill(dataTable);

            }
            catch (Exception ex)
            {
                json.Result = "Failed";
                json.Msg = ex.Message;
            }

            for (var i = 0; i < dataTable.Rows.Count; i++)
            {
                var placeName = dataTable.Rows[i]["tName"];
                var startd = dataTable.Rows[i]["startDate"];
                var endd = dataTable.Rows[i]["endDate"];

                innerItem = new ExpandoObject();
                innerItem.tname = placeName.ToString();
                innerItem.startd = startd.ToString();
                innerItem.endd = endd == null ? "" : endd.ToString();
                terminalDetails.Add(innerItem);


                json.Result = "Success";
                json.Msg = terminalDetails;
            }

            result = Newtonsoft.Json.JsonConvert.SerializeObject(json); 
            
            return result;
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