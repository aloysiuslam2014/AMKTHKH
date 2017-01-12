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
            context.Response.Write(returnoutput);
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
            SqlParameter visitors = new SqlParameter("@Visitors", System.Data.SqlDbType.VarChar);
            respon.Direction = ParameterDirection.Output;
            SqlParameter visitorDetails = new SqlParameter("@Visitor_Details", System.Data.SqlDbType.VarChar);
            respon.Direction = ParameterDirection.Output;

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