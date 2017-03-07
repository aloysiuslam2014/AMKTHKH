using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using System;
using System.Collections;
using System.Collections.Generic;
using System.Data;
using System.Dynamic;
using System.Globalization;
using System.Linq;
using System.Web;
using THKH.Classes.DAO;
using THKH.Classes.Entity;

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
            var returnoutput = "";
            if (action.Equals("getValidTerminals"))
            {
                var query = context.Request.Form["queries"];
                returnoutput = getValidTerminals(query);
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

        private String unifiedTrace(String query)
        {
            String result = "";

            String[] queryParts = query.Split('~');
            String bedORloc = queryParts[0];
            String uq_startdate_str = queryParts[1];
            String uq_enddate_str = queryParts[2];
            DateTime uq_startdate = DateTime.ParseExact(uq_startdate_str, "yyyy-MM-dd", CultureInfo.InvariantCulture); // Might be time format issue
            DateTime uq_enddate = DateTime.ParseExact(uq_enddate_str, "yyyy-MM-dd", CultureInfo.InvariantCulture);
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
            if (bedORloc == "bybed")
            {
                for (var i = 0; i < processed_uq_place_arr.Length; i++)
                {
                    String singleBedResult = traceByRegBed(uq_startdate, uq_enddate, processed_uq_place_arr[i]);
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

                }

                for (var i = 0; i < processed_uq_place_arr.Length; i++)
                {
                    String singleBedResult = traceByScanBed(uq_startdate, uq_enddate, processed_uq_place_arr[i]);
                    if (singleBedResult != "")
                    {
                        JObject obj = JObject.Parse(singleBedResult);
                        JArray arr = (JArray)obj["Msg"];
                        foreach (JToken item in arr.Children())
                        {
                            String entry = item.Value<JObject>().ToString(Formatting.None);
                            byScan_response_visitors.Add(entry);
                        }
                    }
                }
            }

            if (bedORloc == "byloc")
            {
                for (var i = 0; i < processed_uq_place_arr.Length; i++)
                {
                    String singleBedResult = traceByRegLoc(uq_startdate, uq_enddate, processed_uq_place_arr[i]);
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

                }

                for (var i = 0; i < processed_uq_place_arr.Length; i++)
                {
                    String singleBedResult = traceByScanLoc(uq_startdate, uq_enddate, processed_uq_place_arr[i]);
                    if (singleBedResult != "")
                    {
                        JObject obj = JObject.Parse(singleBedResult);
                        JArray arr = (JArray)obj["Msg"];
                        foreach (JToken item in arr.Children())
                        {
                            String entry = item.Value<JObject>().ToString(Formatting.None);
                            byScan_response_visitors.Add(entry);
                        }
                    }
                }
            }

            List<String> reg_and_scan = (List<String>)byReg_response_visitors.Intersect(byScan_response_visitors).ToList();
            List<String> reg_only = (List<String>)byReg_response_visitors.Except(reg_and_scan).ToList();
            List<String> scan_only = (List<String>)byScan_response_visitors.Except(reg_and_scan).ToList();

            List<Tuple<List<String>, bool, bool>> categorizedResults = new List<Tuple<List<String>, bool, bool>>();
            categorizedResults.Add(new Tuple<List<String>, bool, bool>(reg_and_scan, true, true));
            categorizedResults.Add(new Tuple<List<String>, bool, bool>(reg_only, true, false));
            categorizedResults.Add(new Tuple<List<String>, bool, bool>(scan_only, false, true));

            result = buildDisplayResults(categorizedResults);

            return result;
        }

        private String buildDisplayResults(List<Tuple<List<String>, bool, bool>> categorizedResults)
        {
            List<dynamic> serializedResults1 = new List<dynamic>();
            List<List<String>> datatable_array = new List<List<String>>();

            dynamic json = new ExpandoObject();
            dynamic innerItem = new ExpandoObject();

            foreach (Tuple<List<String>, bool, bool> category in categorizedResults)
            {
                List<String> visitList = category.Item1;
                bool reg = category.Item2;
                bool scan = category.Item3;

                foreach (String visit in visitList)
                {
                    JObject deserializedVisit = JObject.Parse(visit);
                    innerItem = new ExpandoObject();
                    List<String> datatable_arrayitem = new List<String>();

                    innerItem.location = deserializedVisit["location"];
                    innerItem.bedno = deserializedVisit["bedno"];
                    innerItem.checkin_time = deserializedVisit["checkin_time"];
                    innerItem.exit_time = deserializedVisit["exit_time"];
                    innerItem.fullName = deserializedVisit["fullName"];
                    innerItem.nric = deserializedVisit["nric"];
                    innerItem.mobileTel = deserializedVisit["mobileTel"];
                    innerItem.nationality = deserializedVisit["nationality"];

                    innerItem.gender = deserializedVisit["gender"];
                    innerItem.dob = deserializedVisit["dob"];
                    innerItem.homeadd = deserializedVisit["homeadd"];
                    innerItem.postalcode = deserializedVisit["postalcode"];

                    if (reg) { innerItem.reg = "Y"; } else { innerItem.reg = ""; }
                    if (scan) { innerItem.scan = "Y"; } else { innerItem.scan = ""; }

                    datatable_arrayitem.Add((string)innerItem.location);
                    datatable_arrayitem.Add((string)innerItem.bedno);
                    datatable_arrayitem.Add((string)innerItem.checkin_time);
                    datatable_arrayitem.Add((string)innerItem.exit_time);
                    datatable_arrayitem.Add((string)innerItem.fullName);
                    datatable_arrayitem.Add((string)innerItem.nric);
                    datatable_arrayitem.Add((string)innerItem.gender);
                    datatable_arrayitem.Add((string)innerItem.dob);
                    datatable_arrayitem.Add((string)innerItem.mobileTel);
                    datatable_arrayitem.Add((string)innerItem.homeadd);
                    datatable_arrayitem.Add((string)innerItem.postalcode);
                    datatable_arrayitem.Add((string)innerItem.nationality);
                    datatable_arrayitem.Add((string)innerItem.reg);
                    datatable_arrayitem.Add((string)innerItem.scan);
                    datatable_array.Add(datatable_arrayitem);
                    serializedResults1.Add(innerItem);
                }
            }
            json.Result = "Success";
            json.Msg = datatable_array;
            return Newtonsoft.Json.JsonConvert.SerializeObject(json); ;
        }

        private String traceByScanBed(DateTime startdatetime, DateTime enddatetime, String bedno)
        {
            DataTable dt = new DataTable();
            dynamic json = new ExpandoObject();
            dynamic innerItem = new ExpandoObject();
            List<Object> jsonArray = new List<Object>();
            GenericProcedureDAO procedureCall = new GenericProcedureDAO("TRACE_BY_SCAN_BED", true, true, true);
            procedureCall.addParameter("@responseMessage", SqlDbType.Int);
            procedureCall.addParameterWithValue("@pStart_Date", startdatetime);
            procedureCall.addParameterWithValue("@pEnd_Date", enddatetime);
            procedureCall.addParameterWithValue("@pBed_No", bedno);
            try
            {
                ProcedureResponse resultss = procedureCall.runProcedure();
                dt = resultss.getDataTable();
               
                for (var i = 0; i < dt.Rows.Count; i++)
                {
                    var location = dt.Rows[i]["location"];
                    var regbedno = dt.Rows[i]["bedno"];
                    var visitActualTime = dt.Rows[i]["checkin_time"];
                    var exitTime = dt.Rows[i]["exit_time"];
                    var visitorNric = dt.Rows[i]["nric"];
                    var fullName = dt.Rows[i]["fullName"];
                    var gender = dt.Rows[i]["gender"];
                    var dob = dt.Rows[i]["dob"];
                    var nationality = dt.Rows[i]["nationality"];
                    var mobileTel = dt.Rows[i]["mobileTel"];
                    var homeadd = dt.Rows[i]["homeadd"];
                    var postalcode = dt.Rows[i]["postalcode"];

                    innerItem = new ExpandoObject();
                    innerItem.location = location.ToString();
                    innerItem.bedno = regbedno.ToString();
                    innerItem.checkin_time = visitActualTime.ToString();
                    innerItem.exit_time = exitTime.ToString();
                    innerItem.nric = visitorNric.ToString();
                    innerItem.fullName = fullName.ToString();
                    innerItem.nationality = nationality.ToString();
                    innerItem.mobileTel = mobileTel.ToString();

                    innerItem.gender = gender.ToString();
                    innerItem.dob = dob.ToString();
                    innerItem.homeadd = homeadd.ToString();
                    innerItem.postalcode = postalcode.ToString();

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
            return Newtonsoft.Json.JsonConvert.SerializeObject(json);
        }

        private String traceByRegBed(DateTime startdatetime, DateTime enddatetime, String bedno)
        {
            DataTable dt = new DataTable();
            dynamic json = new ExpandoObject();
            dynamic innerItem = new ExpandoObject();
            List<Object> jsonArray = new List<Object>();
            GenericProcedureDAO procedureCall = new GenericProcedureDAO("TRACE_BY_REG_BED", true, true, true);
            procedureCall.addParameter("@responseMessage", SqlDbType.Int);
            procedureCall.addParameterWithValue("@pStart_Date", startdatetime);
            procedureCall.addParameterWithValue("@pEnd_Date", enddatetime);
            procedureCall.addParameterWithValue("@pBed_No", bedno);
            try
            {
                ProcedureResponse resultss = procedureCall.runProcedure();
                dt = resultss.getDataTable();
                for (var i = 0; i < dt.Rows.Count; i++)
                {
                    var location = dt.Rows[i]["location"];
                    var regbedno = dt.Rows[i]["bedno"];
                    var visitActualTime = dt.Rows[i]["checkin_time"];
                    var exitTime = dt.Rows[i]["exit_time"];
                    var visitorNric = dt.Rows[i]["nric"];
                    var fullName = dt.Rows[i]["fullName"];
                    var gender = dt.Rows[i]["gender"];
                    var dob = dt.Rows[i]["dob"];
                    var nationality = dt.Rows[i]["nationality"];
                    var mobileTel = dt.Rows[i]["mobileTel"];
                    var homeadd = dt.Rows[i]["homeadd"];
                    var postalcode = dt.Rows[i]["postalcode"];
                    innerItem = new ExpandoObject();
                    innerItem.location = location.ToString();
                    innerItem.bedno = regbedno.ToString();
                    innerItem.checkin_time = visitActualTime.ToString();
                    innerItem.exit_time = exitTime.ToString();
                    innerItem.nric = visitorNric.ToString();
                    innerItem.fullName = fullName.ToString();
                    innerItem.nationality = nationality.ToString();
                    innerItem.mobileTel = mobileTel.ToString();
                    innerItem.gender = gender.ToString();
                    innerItem.dob = dob.ToString();
                    innerItem.homeadd = homeadd.ToString();
                    innerItem.postalcode = postalcode.ToString();
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
            return Newtonsoft.Json.JsonConvert.SerializeObject(json);
        }

        private String traceByScanLoc(DateTime startdatetime, DateTime enddatetime, String loc)
        {
            DataTable dt = new DataTable();
            dynamic json = new ExpandoObject();
            dynamic innerItem = new ExpandoObject();
            List<Object> jsonArray = new List<Object>();
            GenericProcedureDAO procedureCall = new GenericProcedureDAO("TRACE_BY_REG_BED", true, true, true);
            procedureCall.addParameter("@responseMessage", SqlDbType.Int);
            procedureCall.addParameterWithValue("@pStart_Date", startdatetime);
            procedureCall.addParameterWithValue("@pEnd_Date", enddatetime);
            procedureCall.addParameterWithValue("@pLocation", loc);
            try
            {
                ProcedureResponse resultss = procedureCall.runProcedure();
                dt = resultss.getDataTable();
                for (var i = 0; i < dt.Rows.Count; i++)
                {
                    var location = dt.Rows[i]["location"];
                    var regbedno = dt.Rows[i]["bedno"];
                    var visitActualTime = dt.Rows[i]["checkin_time"];
                    var exitTime = dt.Rows[i]["exit_time"];
                    var visitorNric = dt.Rows[i]["nric"];
                    var fullName = dt.Rows[i]["fullName"];
                    var gender = dt.Rows[i]["gender"];
                    var dob = dt.Rows[i]["dob"];
                    var nationality = dt.Rows[i]["nationality"];
                    var mobileTel = dt.Rows[i]["mobileTel"];
                    var homeadd = dt.Rows[i]["homeadd"];
                    var postalcode = dt.Rows[i]["postalcode"];

                    innerItem = new ExpandoObject();
                    innerItem.location = location.ToString();
                    innerItem.bedno = regbedno.ToString();
                    innerItem.checkin_time = visitActualTime.ToString();
                    innerItem.exit_time = exitTime.ToString();
                    innerItem.nric = visitorNric.ToString();
                    innerItem.fullName = fullName.ToString();
                    innerItem.nationality = nationality.ToString();
                    innerItem.mobileTel = mobileTel.ToString();
                    innerItem.gender = gender.ToString();
                    innerItem.dob = dob.ToString();
                    innerItem.homeadd = homeadd.ToString();
                    innerItem.postalcode = postalcode.ToString();
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
            return Newtonsoft.Json.JsonConvert.SerializeObject(json); ;
        }

        private String traceByRegLoc(DateTime startdatetime, DateTime enddatetime, String loc)
        {
            DataTable dt = new DataTable();
            dynamic json = new ExpandoObject();
            dynamic innerItem = new ExpandoObject();
            List<Object> jsonArray = new List<Object>();
            GenericProcedureDAO procedureCall = new GenericProcedureDAO("TRACE_BY_REG_LOC", true, true, true);
            procedureCall.addParameter("@responseMessage", SqlDbType.Int);
            procedureCall.addParameterWithValue("@pStart_Date", startdatetime);
            procedureCall.addParameterWithValue("@pEnd_Date", enddatetime);
            procedureCall.addParameterWithValue("@pLocation", loc);
            try
            {
                ProcedureResponse resultss = procedureCall.runProcedure();
                dt = resultss.getDataTable();
                for (var i = 0; i < dt.Rows.Count; i++)
                {
                    var location = dt.Rows[i]["location"];
                    var regbedno = dt.Rows[i]["bedno"];
                    var visitActualTime = dt.Rows[i]["checkin_time"];
                    var exitTime = dt.Rows[i]["exit_time"];
                    var visitorNric = dt.Rows[i]["nric"];
                    var fullName = dt.Rows[i]["fullName"];
                    var gender = dt.Rows[i]["gender"];
                    var dob = dt.Rows[i]["dob"];
                    var nationality = dt.Rows[i]["nationality"];
                    var mobileTel = dt.Rows[i]["mobileTel"];
                    var homeadd = dt.Rows[i]["homeadd"];
                    var postalcode = dt.Rows[i]["postalcode"];

                    innerItem = new ExpandoObject();
                    innerItem.location = location.ToString();
                    innerItem.bedno = regbedno.ToString();
                    innerItem.checkin_time = visitActualTime.ToString();
                    innerItem.exit_time = exitTime.ToString();
                    innerItem.nric = visitorNric.ToString();
                    innerItem.fullName = fullName.ToString();
                    innerItem.nationality = nationality.ToString();
                    innerItem.mobileTel = mobileTel.ToString();
                    innerItem.gender = gender.ToString();
                    innerItem.dob = dob.ToString();
                    innerItem.homeadd = homeadd.ToString();
                    innerItem.postalcode = postalcode.ToString();
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
            return Newtonsoft.Json.JsonConvert.SerializeObject(json);
        }

        private String[] processBedNos(String[] bedno_arr)
        {
            ArrayList result = new ArrayList();

            for (var i = 0; i < bedno_arr.Length; i++)
            {
                String thisBedNoToken = bedno_arr[i];

                if (thisBedNoToken.Contains("-"))
                {
                    String[] bednoRange = thisBedNoToken.Split('-');
                    Int32 rangeStart = Int32.Parse(bednoRange[0]);
                    Int32 rangeEnd = Int32.Parse(bednoRange[1]);
                    int rangeCount = rangeEnd - rangeStart + 1;

                    int[] processed_bedrange = Enumerable.Range(rangeStart, rangeCount).ToArray();

                    foreach (int bedno in processed_bedrange)
                    {
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

        private String traceByReg(String query)
        {
            String[] queryParts = query.Split('~');
            DateTime ri_dateStart = DateTime.Parse(queryParts[0]);
            DateTime ri_dateEnd = DateTime.Parse(queryParts[1]);
            String bedNo = queryParts[2];

            dynamic json = new ExpandoObject();
            dynamic innerItem = new ExpandoObject();
            ArrayList byBedNoResults = new ArrayList();

            GenericProcedureDAO procedureCall = new GenericProcedureDAO("GET_TRACE_BEDNO", true, true, false);
            procedureCall.addParameter("@responseMessage", SqlDbType.Int);
            procedureCall.addParameter("@Visitors", System.Data.SqlDbType.NVarChar, 4000);
            procedureCall.addParameter("@Visitor_Details", System.Data.SqlDbType.NVarChar, 4000);
            procedureCall.addParameterWithValue("@pStart_Date", ri_dateStart);
            procedureCall.addParameterWithValue("@pEnd_Date", ri_dateEnd);
            procedureCall.addParameterWithValue("@pBed_No", bedNo);
            try
            {
                ProcedureResponse resultss = procedureCall.runProcedure();
                String response_visitors = resultss.getSqlParameterValue("@Visitors").ToString();
                String response_visitorDetails = resultss.getSqlParameterValue("@Visitor_Details").ToString();
                innerItem.visitors = response_visitors;
                innerItem.visitorDetails = response_visitorDetails;
                byBedNoResults.Add(innerItem);
            }
            catch (Exception ex)
            {
                json.Result = "Failed";
                json.Msg = ex.Message;
            }

            json.Result = "Success";
            json.Msg = byBedNoResults;
            return Newtonsoft.Json.JsonConvert.SerializeObject(json);
        }

        private String getValidTerminals(String query)
        {
            DataTable dataTable = new DataTable();
            string startString = query.Split('~').First();
            string endString = query.Split('~').Last();
            DateTime startDate = DateTime.Parse(startString);
            DateTime endDate = DateTime.Parse(endString);
            dynamic json = new ExpandoObject();
            dynamic innerItem = new ExpandoObject();
            ArrayList terminalDetails = new ArrayList();
            GenericProcedureDAO procedureCall = new GenericProcedureDAO("GET_TRACE_TERMINALS", true, true, true);
            procedureCall.addParameter("@responseMessage", SqlDbType.Int);
            procedureCall.addParameterWithValue("@pStart_Date", startDate);
            procedureCall.addParameterWithValue("@pEnd_Date", endDate);
            try
            {
                ProcedureResponse resultss = procedureCall.runProcedure();
                dataTable = resultss.getDataTable();
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
            return Newtonsoft.Json.JsonConvert.SerializeObject(json);
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