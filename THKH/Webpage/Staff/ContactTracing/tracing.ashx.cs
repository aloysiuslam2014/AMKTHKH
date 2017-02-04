using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using System;
using System.Collections;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Dynamic;
using System.Globalization;
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

        private String unifiedTrace(String query) {
            String result = "";

            String[] queryParts = query.Split('~');
            String bedORloc = queryParts[0];
            String uq_startdate_str = queryParts[1];
            String uq_enddate_str = queryParts[2];
            DateTime uq_startdate = DateTime.ParseExact(uq_startdate_str, "dd-MM-yyyy", CultureInfo.InvariantCulture); // Might be time format issue
            DateTime uq_enddate = DateTime.ParseExact(uq_enddate_str, "dd-MM-yyyy", CultureInfo.InvariantCulture);
            //DateTime uq_enddate = DateTime.ParseExact(uq_enddate_str, "MM/dd/yyyy h:mm tt", null);
            String uq_place = queryParts[3];
            String[] uq_place_arr = uq_place.Split(',');

            String[] processed_uq_place_arr = uq_place_arr;
   
            if (bedORloc == "bybed")
            {
                processed_uq_place_arr = processBedNos(uq_place_arr);
            }
            

            List<String> byReg_response_visitors = new List<String>();
            List<String> byScan_response_visitors = new List<String>();
            
            dynamic json = new ExpandoObject();
            dynamic innerItem = new ExpandoObject();

            //trace by bedno
            if (bedORloc == "bybed") {
                for (var i = 0; i < processed_uq_place_arr.Length; i++)
                {
                    String singleBedResult = traceByRegBed(uq_startdate, uq_enddate, processed_uq_place_arr[i]);
                    //List<String> singleBedResult_toList = new List<String>();
                    if (singleBedResult != "") {
                        //Object obj = Newtonsoft.Json.JsonConvert.DeserializeObject<Object>(singleBedResult);
                        JObject obj = JObject.Parse(singleBedResult);
                        JArray arr = (JArray)obj["Msg"];
                        foreach (JToken item in arr.Children()) {
                            String entry = item.Value<JObject>().ToString(Formatting.None);
                            byReg_response_visitors.Add(entry);
                        }
                        // singleBedResult_toList = Newtonsoft.Json.JsonConvert.DeserializeObject<List<String>>(singleBedResult); // Invalid Cast
                    }
                    //byReg_response_visitors.AddRange(singleBedResult_toList);

                }

                for (var i = 0; i < processed_uq_place_arr.Length; i++)
                {
                    String singleBedResult = traceByScanBed(uq_startdate, uq_enddate, processed_uq_place_arr[i]);
                    //List<String> singleBedResult_toList = new List<String>();
                    if (singleBedResult != "")
                    {
                        JObject obj = JObject.Parse(singleBedResult);
                        JArray arr = (JArray)obj["Msg"];
                        foreach (JToken item in arr.Children())
                        {
                            String entry = item.Value<JObject>().ToString(Formatting.None);
                            byScan_response_visitors.Add(entry);
                        }
                        //singleBedResult_toList = (List<String>)Newtonsoft.Json.JsonConvert.DeserializeObject(singleBedResult);
                    }
                    //byScan_response_visitors.AddRange(singleBedResult_toList);
                }
            }

            if (bedORloc == "byloc") {
                for (var i = 0; i < processed_uq_place_arr.Length; i++)
                {
                    String singleBedResult = traceByRegLoc(uq_startdate, uq_enddate, processed_uq_place_arr[i]);
                    //List<String> singleBedResult_toList = new List<String>();
                    if (singleBedResult != "")
                    {
                        JObject obj = JObject.Parse(singleBedResult);
                        JArray arr = (JArray)obj["Msg"];
                        foreach (JToken item in arr.Children())
                        {
                            String entry = item.Value<JObject>().ToString(Formatting.None);
                            byReg_response_visitors.Add(entry);
                        }
                    }
                    //byReg_response_visitors.AddRange(singleBedResult_toList);

                }

                for (var i = 0; i < processed_uq_place_arr.Length; i++)
                {
                    String singleBedResult = traceByScanLoc(uq_startdate, uq_enddate, processed_uq_place_arr[i]);
                    //List<String> singleBedResult_toList = new List<String>();
                    if (singleBedResult != "")
                    {
                        JObject obj = JObject.Parse(singleBedResult);
                        JArray arr = (JArray)obj["Msg"];
                        foreach (JToken item in arr.Children())
                        {
                            String entry = item.Value<JObject>().ToString(Formatting.None);
                            byScan_response_visitors.Add(entry);
                        }
                        //singleBedResult_toList = (List<String>)Newtonsoft.Json.JsonConvert.DeserializeObject(singleBedResult);
                    }
                    //byScan_response_visitors.AddRange(singleBedResult_toList);
                }
            }

            //find the intersects, and derive the other 2 categories.
            List<String> reg_and_scan = (List<String>)byReg_response_visitors.Intersect(byScan_response_visitors).ToList();
            List<String> reg_only = (List<String>)byReg_response_visitors.Except(reg_and_scan).ToList();
            List<String> scan_only = (List<String>)byScan_response_visitors.Except(reg_and_scan).ToList();

            List<Tuple<List<String>, bool, bool>> categorizedResults = new List<Tuple<List<String>, bool, bool>>();
            categorizedResults.Add(new Tuple<List<String>, bool, bool>(reg_and_scan, true, true));
            categorizedResults.Add(new Tuple<List<String>, bool, bool>(reg_only, true, false));
            categorizedResults.Add(new Tuple<List<String>, bool, bool>(scan_only, false, true));

            //construct and return Expando Object with only the parameters required for the display table.
            result = buildDisplayResults(categorizedResults);

            return result;
        }

        private String buildDisplayResults(List<Tuple<List<String>, bool, bool>> categorizedResults) {
            String result = "";
            List<String> serializedResults = new List<String>();
            List<dynamic> serializedResults1 = new List<dynamic>();

            dynamic json = new ExpandoObject();
            dynamic innerItem = new ExpandoObject();

            foreach (Tuple<List<String>, bool, bool> category in categorizedResults) {
                List<String> visitList = category.Item1;
                bool reg = category.Item2;
                bool scan = category.Item3;

                foreach (String visit in visitList) {
                    //dynamic deserializedVisit = Newtonsoft.Json.JsonConvert.DeserializeObject(visit);
                    JObject deserializedVisit = JObject.Parse(visit);
                    innerItem = new ExpandoObject();

                    //innerItem.location = deserializedVisit.visitLocation;
                    //innerItem.bedno = deserializedVisit.bedNo;
                    //innerItem.checkin_time = deserializedVisit.visitActualTime;
                    //innerItem.exit_time = deserializedVisit.exitTime;
                    //innerItem.fullName = deserializedVisit.fullName;
                    //innerItem.nric = deserializedVisit.visitorNric;
                    //innerItem.mobileTel = deserializedVisit.mobileTel;
                    //innerItem.nationality = deserializedVisit.nationality;

                    innerItem.location = deserializedVisit["location"];
                    innerItem.bedno = deserializedVisit["bedno"];
                    innerItem.checkin_time = deserializedVisit["checkin_time"];
                    innerItem.exit_time = deserializedVisit["exit_time"];
                    innerItem.fullName = deserializedVisit["fullName"];
                    innerItem.nric = deserializedVisit["nric"];
                    innerItem.mobileTel = deserializedVisit["mobileTel"];
                    innerItem.nationality = deserializedVisit["nationality"];

                    if (reg) { innerItem.reg = "Yes"; } else { innerItem.reg = "No"; }
                    if (scan) { innerItem.scan = "Yes"; } else { innerItem.scan = "No"; }

                    serializedResults1.Add(innerItem);
                    //String serializedResult = Newtonsoft.Json.JsonConvert.SerializeObject(innerItem);
                    //serializedResults.Add(serializedResult);
                }
            }
            json.Result = "Success";
            json.Msg = serializedResults1.ToArray();
            //json.Msg = serializedResults;

            result = Newtonsoft.Json.JsonConvert.SerializeObject(json);

            return result;
        }

        private String traceByScanBed(DateTime startdatetime, DateTime enddatetime, String bedno)
        {
            SqlConnection cnn;
            cnn = new SqlConnection(System.Configuration.ConfigurationManager.ConnectionStrings["offlineConnection"].ConnectionString);
            SqlParameter respon = new SqlParameter("@responseMessage", System.Data.SqlDbType.Int);
            respon.Direction = ParameterDirection.Output;
            //SqlParameter visitors = new SqlParameter("@pVisits", System.Data.SqlDbType.NVarChar);
            //visitors.Direction = ParameterDirection.Output;
            //visitors.Size = 4000;
            DataTable dt = new DataTable();
            dynamic json = new ExpandoObject();
            dynamic innerItem = new ExpandoObject();
            List<Object> jsonArray = new List<Object>();

            try
            {
                SqlCommand command = new SqlCommand("[dbo].[TRACE_BY_SCAN_BED]", cnn);
                command.CommandType = System.Data.CommandType.StoredProcedure;
                command.Parameters.AddWithValue("@pStart_Date", startdatetime);
                command.Parameters.AddWithValue("@pEnd_Date", enddatetime);
                command.Parameters.AddWithValue("@pBed_No", bedno);
                SqlDataAdapter da = new SqlDataAdapter(command);

                command.Parameters.Add(respon);
                da.Fill(dt);
                //command.Parameters.Add(visitors);
                //cnn.Open();
                //command.ExecuteNonQuery();

                for (var i = 0; i < dt.Rows.Count; i++)
                {
                    var location = dt.Rows[i]["location"];
                    var regbedno = dt.Rows[i]["bedno"];
                    var visitActualTime = dt.Rows[i]["checkin_time"];
                    var exitTime = dt.Rows[i]["exit_time"];
                    var visitorNric = dt.Rows[i]["nric"];
                    var fullName = dt.Rows[i]["fullName"];
                    var nationality = dt.Rows[i]["nationality"];
                    var mobileTel = dt.Rows[i]["mobileTel"];

                    innerItem = new ExpandoObject();
                    innerItem.location = location.ToString();
                    innerItem.bedno = regbedno.ToString();
                    innerItem.checkin_time = visitActualTime.ToString();
                    innerItem.exit_time = exitTime.ToString();
                    innerItem.nric = visitorNric.ToString();
                    innerItem.fullName = fullName.ToString();
                    innerItem.nationality = nationality.ToString();
                    innerItem.mobileTel = mobileTel.ToString();
                    jsonArray.Add(innerItem);
                }
                json.Result = "Success";
                json.Msg = jsonArray;
            }
            catch (Exception ex)
            {
                json.Result = "Failed";
                json.Msg = ex.Message;
            }

            //String byScanBed_response_visitors = visitors.Value.ToString(); // json array of json objects, each of which is a visitor

            //json.Result = "Success";
            //json.Msg = byScanBed_response_visitors;

            String result = Newtonsoft.Json.JsonConvert.SerializeObject(json);

            return result;
        }

        private String traceByRegBed(DateTime startdatetime, DateTime enddatetime, String bedno) {

            SqlConnection cnn;
            cnn = new SqlConnection(System.Configuration.ConfigurationManager.ConnectionStrings["offlineConnection"].ConnectionString);
            SqlParameter respon = new SqlParameter("@responseMessage", System.Data.SqlDbType.Int);
            respon.Direction = ParameterDirection.Output;
            //SqlParameter visitors = new SqlParameter("@pVisits", System.Data.SqlDbType.NVarChar);
            //visitors.Direction = ParameterDirection.Output;
            //visitors.Size = 4000;
            DataTable dt = new DataTable();
            dynamic json = new ExpandoObject();
            dynamic innerItem = new ExpandoObject();
            List<Object> jsonArray = new List<Object>();

            try
            {
                SqlCommand command = new SqlCommand("[dbo].[TRACE_BY_REG_BED]", cnn);
                command.CommandType = System.Data.CommandType.StoredProcedure;
                command.Parameters.AddWithValue("@pStart_Date", startdatetime);
                command.Parameters.AddWithValue("@pEnd_Date", enddatetime);
                command.Parameters.AddWithValue("@pBed_No", bedno);
                SqlDataAdapter da = new SqlDataAdapter(command);

                command.Parameters.Add(respon);
                da.Fill(dt);
                //command.Parameters.Add(visitors);
                //cnn.Open();
                //command.ExecuteNonQuery();

                // Initiate reader here & construct JSON Object
                // columns will be returned like this
                //visitLocation VARCHAR(100),
                //bedno INT,
                //visitActualTime DATETIME,
                //exitTime DATETIME,
                //visitorNric VARCHAR(15),
                //fullName VARCHAR(150),
                //nationality VARCHAR(300),
                //mobileTel VARCHAR(20))

                //SqlDataReader reader = command.ExecuteReader();
                //if (reader.HasRows)
                //{
                //    while (reader.Read())
                //    {
                //        // Construct JSON Object here

                //    }
                //}
                //reader.Close();

                for (var i = 0; i < dt.Rows.Count; i++)
                {
                    var location = dt.Rows[i]["location"];
                    var regbedno = dt.Rows[i]["bedno"];
                    var visitActualTime = dt.Rows[i]["checkin_time"];
                    var exitTime = dt.Rows[i]["exit_time"];
                    var visitorNric = dt.Rows[i]["nric"];
                    var fullName = dt.Rows[i]["fullName"];
                    var nationality = dt.Rows[i]["nationality"];
                    var mobileTel = dt.Rows[i]["mobileTel"];

                    innerItem = new ExpandoObject();
                    innerItem.location = location.ToString();
                    innerItem.bedno = regbedno.ToString();
                    innerItem.checkin_time = visitActualTime.ToString();
                    innerItem.exit_time = exitTime == null ? "" : exitTime.ToString();
                    innerItem.nric = visitorNric.ToString();
                    innerItem.fullName = fullName.ToString();
                    innerItem.nationality = nationality.ToString();
                    innerItem.mobileTel = mobileTel.ToString();
                    jsonArray.Add(innerItem);
                }
                json.Result = "Success";
                json.Msg = jsonArray;

                //dt.Load(command.ExecuteReader());
                //List<Object> jsonArray = new List<Object>();
                //foreach (DataRow row in dt.Rows) {
                //    dynamic innerJson = new ExpandoObject();
                //    var itemArr = row.ItemArray;
                //    innerJson.location = itemArr[0];
                //    innerJson.bedno = itemArr[1];
                //    innerJson.checkin_time = itemArr[2];
                //    innerJson.exit_time = itemArr[3];
                //    innerJson.fullName = itemArr[5];
                //    innerJson.nric = itemArr[4];
                //    innerJson.mobileTel = itemArr[7];
                //    innerJson.nationality = itemArr[6];
                //    // Add to JSON Array
                //    jsonArray.Add(innerJson);
                //}
                //// Add JSON Array to JSON Object
                //json.Msg = jsonArray;
            }
            catch (Exception ex)
            {
                json.Result = "Failed";
                json.Msg = ex.Message;
            }

            //String byRegBed_response_visitors = visitors.Value.ToString(); // json array of json objects, each of which is a visitor

            //json.Result = "Success";
            //json.Msg = byRegBed_response_visitors;

            String result = Newtonsoft.Json.JsonConvert.SerializeObject(json);
            return result;
        }

        private String traceByScanLoc(DateTime startdatetime, DateTime enddatetime, String loc)
        {
           
            SqlConnection cnn;
            cnn = new SqlConnection(System.Configuration.ConfigurationManager.ConnectionStrings["offlineConnection"].ConnectionString);
            SqlParameter respon = new SqlParameter("@responseMessage", System.Data.SqlDbType.Int);
            respon.Direction = ParameterDirection.Output;
            //SqlParameter visitors = new SqlParameter("@pVisits", System.Data.SqlDbType.NVarChar);
            //visitors.Direction = ParameterDirection.Output;
            //visitors.Size = 4000;
            DataTable dt = new DataTable();
            dynamic json = new ExpandoObject();
            dynamic innerItem = new ExpandoObject();
            List<Object> jsonArray = new List<Object>();

            try
            {
                SqlCommand command = new SqlCommand("[dbo].[TRACE_BY_SCAN_LOC]", cnn);
                command.CommandType = System.Data.CommandType.StoredProcedure;
                command.Parameters.AddWithValue("@pStart_Date", startdatetime);
                command.Parameters.AddWithValue("@pEnd_Date", enddatetime);
                command.Parameters.AddWithValue("@pLocation", loc);
                SqlDataAdapter da = new SqlDataAdapter(command);

                command.Parameters.Add(respon);
                da.Fill(dt);
                //command.Parameters.Add(visitors);
                //cnn.Open();
                //command.ExecuteNonQuery();

                for (var i = 0; i < dt.Rows.Count; i++)
                {
                    var location = dt.Rows[i]["location"];
                    var regbedno = dt.Rows[i]["bedno"];
                    var visitActualTime = dt.Rows[i]["checkin_time"];
                    var exitTime = dt.Rows[i]["exit_time"];
                    var visitorNric = dt.Rows[i]["nric"];
                    var fullName = dt.Rows[i]["fullName"];
                    var nationality = dt.Rows[i]["nationality"];
                    var mobileTel = dt.Rows[i]["mobileTel"];

                    innerItem = new ExpandoObject();
                    innerItem.location = location.ToString();
                    innerItem.bedno = regbedno.ToString();
                    innerItem.checkin_time = visitActualTime.ToString();
                    innerItem.exit_time = exitTime.ToString();
                    innerItem.nric = visitorNric.ToString();
                    innerItem.fullName = fullName.ToString();
                    innerItem.nationality = nationality.ToString();
                    innerItem.mobileTel = mobileTel.ToString();
                    jsonArray.Add(innerItem);
                }
                json.Result = "Success";
                json.Msg = jsonArray;

            }
            catch (Exception ex)
            {
                json.Result = "Failed";
                json.Msg = ex.Message;
            }

            //String byScanLoc_response_visitors = visitors.Value.ToString(); // json array of json objects, each of which is a visitor

            //json.Result = "Success";
            //json.Msg = byScanBed_response_visitors;

            String result = Newtonsoft.Json.JsonConvert.SerializeObject(json);

            return result;
        }

        private String traceByRegLoc(DateTime startdatetime, DateTime enddatetime, String loc)
        {

            SqlConnection cnn;
            cnn = new SqlConnection(System.Configuration.ConfigurationManager.ConnectionStrings["offlineConnection"].ConnectionString);
            SqlParameter respon = new SqlParameter("@responseMessage", System.Data.SqlDbType.Int);
            respon.Direction = ParameterDirection.Output;
            //SqlParameter visitors = new SqlParameter("@pVisits", System.Data.SqlDbType.NVarChar);
            //visitors.Direction = ParameterDirection.Output;
            //visitors.Size = 4000;
            DataTable dt = new DataTable();
            dynamic json = new ExpandoObject();
            dynamic innerItem = new ExpandoObject();
            List<Object> jsonArray = new List<Object>();

            try
            {
                SqlCommand command = new SqlCommand("[dbo].[TRACE_BY_REG_LOC]", cnn);
                command.CommandType = System.Data.CommandType.StoredProcedure;
                command.Parameters.AddWithValue("@pStart_Date", startdatetime);
                command.Parameters.AddWithValue("@pEnd_Date", enddatetime);
                command.Parameters.AddWithValue("@pLocation", loc);
                SqlDataAdapter da = new SqlDataAdapter(command);

                command.Parameters.Add(respon);
                da.Fill(dt);
                //command.Parameters.Add(visitors);
                //cnn.Open();
                //command.ExecuteNonQuery();

                for (var i = 0; i < dt.Rows.Count; i++)
                {
                    var location = dt.Rows[i]["location"];
                    var regbedno = dt.Rows[i]["bedno"];
                    var visitActualTime = dt.Rows[i]["checkin_time"];
                    var exitTime = dt.Rows[i]["exit_time"];
                    var visitorNric = dt.Rows[i]["nric"];
                    var fullName = dt.Rows[i]["fullName"];
                    var nationality = dt.Rows[i]["nationality"];
                    var mobileTel = dt.Rows[i]["mobileTel"];

                    innerItem = new ExpandoObject();
                    innerItem.location = location.ToString();
                    innerItem.bedno = regbedno.ToString();
                    innerItem.checkin_time = visitActualTime.ToString();
                    innerItem.exit_time = exitTime == null ? "" : exitTime.ToString();
                    innerItem.nric = visitorNric.ToString();
                    innerItem.fullName = fullName.ToString();
                    innerItem.nationality = nationality.ToString();
                    innerItem.mobileTel = mobileTel.ToString();
                    jsonArray.Add(innerItem);
                }
                json.Result = "Success";
                json.Msg = jsonArray;

            }
            catch (Exception ex)
            {
                json.Result = "Failed";
                json.Msg = ex.Message;
            }

            //String byRegLoc_response_visitors = visitors.Value.ToString(); // json array of json objects, each of which is a visitor

            //json.Result = "Success";
            //json.Msg = byRegBed_response_visitors;

            String result = Newtonsoft.Json.JsonConvert.SerializeObject(json);
            return result;
        }

        private String[] processBedNos(String[] bedno_arr) {
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

            return (String[])result.ToArray(typeof(string));
        }

        private String traceByReg(String query) {
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

        private String getValidTerminals(String query)
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