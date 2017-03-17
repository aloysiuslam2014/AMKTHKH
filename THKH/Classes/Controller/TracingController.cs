using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using System;
using System.Collections;
using System.Collections.Generic;
using System.Data;
using System.Dynamic;
using System.Globalization;
using System.Linq;
using THKH.Classes.DAO;
using THKH.Classes.Entity;

namespace THKH.Classes.Controller
{
    public class TracingController
    {

        public String unifiedTrace(String query)
        {
            String result = "";

            String[] queryParts = query.Split('~');
            String bedORloc = queryParts[0];
            String uq_startdate_str = queryParts[1];
            String uq_enddate_str = queryParts[2];
            DateTime uq_startdate = DateTime.ParseExact(uq_startdate_str, "yyyy-MM-dd", CultureInfo.InvariantCulture);
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

        public String buildDisplayResults(List<Tuple<List<String>, bool, bool>> categorizedResults)
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
                    innerItem.temperature = deserializedVisit["temperature"];
                    innerItem.fullName = deserializedVisit["fullName"];
                    innerItem.nric = deserializedVisit["nric"];
                    innerItem.mobileTel = deserializedVisit["mobileTel"];
                    innerItem.nationality = deserializedVisit["nationality"];

                    innerItem.gender = deserializedVisit["gender"];
                    innerItem.dob = deserializedVisit["dob"];
                    innerItem.homeadd = deserializedVisit["homeadd"];
                    innerItem.postalcode = deserializedVisit["postalcode"];

                    innerItem.formAnswers = parseFormJson((string)deserializedVisit["formAnswers"]);

                    if (reg) { innerItem.reg = "Y"; } else { innerItem.reg = ""; }
                    if (scan) { innerItem.scan = "Y"; } else { innerItem.scan = ""; }

                    datatable_arrayitem.Add((string)innerItem.location);
                    datatable_arrayitem.Add((string)innerItem.bedno);
                    datatable_arrayitem.Add((string)innerItem.checkin_time);
                    datatable_arrayitem.Add((string)innerItem.exit_time);
                    datatable_arrayitem.Add((string)innerItem.temperature); //hidden
                    datatable_arrayitem.Add((string)innerItem.fullName);
                    datatable_arrayitem.Add((string)innerItem.nric);
                    datatable_arrayitem.Add((string)innerItem.gender);  //hidden
                    datatable_arrayitem.Add((string)innerItem.dob);     //hidden
                    datatable_arrayitem.Add((string)innerItem.mobileTel);
                    datatable_arrayitem.Add((string)innerItem.homeadd); //hidden
                    datatable_arrayitem.Add((string)innerItem.postalcode);  //hidden
                    datatable_arrayitem.Add((string)innerItem.nationality);
                    datatable_arrayitem.Add((string)innerItem.formAnswers); //hidden
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

        public String traceByScanBed(DateTime startdatetime, DateTime enddatetime, String bedno)
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
                    var temperature = dt.Rows[i]["temperature"];
                    var visitorNric = dt.Rows[i]["nric"];
                    var fullName = dt.Rows[i]["fullName"];
                    var gender = dt.Rows[i]["gender"];
                    var dob = dt.Rows[i]["dob"];
                    var nationality = dt.Rows[i]["nationality"];
                    var mobileTel = dt.Rows[i]["mobileTel"];
                    var homeadd = dt.Rows[i]["homeadd"];
                    var postalcode = dt.Rows[i]["postalcode"];
                    var formAnswers = dt.Rows[i]["formAnswers"];

                    innerItem = new ExpandoObject();
                    innerItem.location = location.ToString();
                    innerItem.bedno = regbedno.ToString();
                    innerItem.checkin_time = visitActualTime.ToString();
                    innerItem.exit_time = exitTime.ToString();
                    innerItem.temperature = temperature.ToString();
                    innerItem.nric = visitorNric.ToString();
                    innerItem.fullName = fullName.ToString();
                    innerItem.nationality = nationality.ToString();
                    innerItem.mobileTel = mobileTel.ToString();
                    innerItem.gender = gender.ToString();
                    innerItem.dob = dob.ToString();
                    innerItem.homeadd = homeadd.ToString();
                    innerItem.postalcode = postalcode.ToString();
                    innerItem.formAnswers = formAnswers.ToString();
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

        public String traceByRegBed(DateTime startdatetime, DateTime enddatetime, String bedno)
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
                    var temperature = dt.Rows[i]["temperature"];
                    var visitorNric = dt.Rows[i]["nric"];
                    var fullName = dt.Rows[i]["fullName"];
                    var gender = dt.Rows[i]["gender"];
                    var dob = dt.Rows[i]["dob"];
                    var nationality = dt.Rows[i]["nationality"];
                    var mobileTel = dt.Rows[i]["mobileTel"];
                    var homeadd = dt.Rows[i]["homeadd"];
                    var postalcode = dt.Rows[i]["postalcode"];
                    var formAnswers = dt.Rows[i]["formAnswers"];

                    innerItem = new ExpandoObject();
                    innerItem.location = location.ToString();
                    innerItem.bedno = regbedno.ToString();
                    innerItem.checkin_time = visitActualTime.ToString();
                    innerItem.exit_time = exitTime.ToString();
                    innerItem.temperature = temperature.ToString();
                    innerItem.nric = visitorNric.ToString();
                    innerItem.fullName = fullName.ToString();
                    innerItem.nationality = nationality.ToString();
                    innerItem.mobileTel = mobileTel.ToString();
                    innerItem.gender = gender.ToString();
                    innerItem.dob = dob.ToString();
                    innerItem.homeadd = homeadd.ToString();
                    innerItem.postalcode = postalcode.ToString();
                    innerItem.formAnswers = formAnswers.ToString();
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

        public String traceByScanLoc(DateTime startdatetime, DateTime enddatetime, String loc)
        {
            DataTable dt = new DataTable();
            dynamic json = new ExpandoObject();
            dynamic innerItem = new ExpandoObject();
            List<Object> jsonArray = new List<Object>();
            GenericProcedureDAO procedureCall = new GenericProcedureDAO("TRACE_BY_SCAN_LOC", true, true, true);
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
                    var temperature = dt.Rows[i]["temperature"];
                    var visitorNric = dt.Rows[i]["nric"];
                    var fullName = dt.Rows[i]["fullName"];
                    var gender = dt.Rows[i]["gender"];
                    var dob = dt.Rows[i]["dob"];
                    var nationality = dt.Rows[i]["nationality"];
                    var mobileTel = dt.Rows[i]["mobileTel"];
                    var homeadd = dt.Rows[i]["homeadd"];
                    var postalcode = dt.Rows[i]["postalcode"];
                    var formAnswers = dt.Rows[i]["formAnswers"];

                    innerItem = new ExpandoObject();
                    innerItem.location = location.ToString();
                    innerItem.bedno = regbedno.ToString();
                    innerItem.checkin_time = visitActualTime.ToString();
                    innerItem.exit_time = exitTime.ToString();
                    innerItem.temperature = temperature.ToString();
                    innerItem.nric = visitorNric.ToString();
                    innerItem.fullName = fullName.ToString();
                    innerItem.nationality = nationality.ToString();
                    innerItem.mobileTel = mobileTel.ToString();
                    innerItem.gender = gender.ToString();
                    innerItem.dob = dob.ToString();
                    innerItem.homeadd = homeadd.ToString();
                    innerItem.postalcode = postalcode.ToString();
                    innerItem.formAnswers = formAnswers.ToString();
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

        public String traceByRegLoc(DateTime startdatetime, DateTime enddatetime, String loc)
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
                    var temperature = dt.Rows[i]["temperature"];
                    var visitorNric = dt.Rows[i]["nric"];
                    var fullName = dt.Rows[i]["fullName"];
                    var gender = dt.Rows[i]["gender"];
                    var dob = dt.Rows[i]["dob"];
                    var nationality = dt.Rows[i]["nationality"];
                    var mobileTel = dt.Rows[i]["mobileTel"];
                    var homeadd = dt.Rows[i]["homeadd"];
                    var postalcode = dt.Rows[i]["postalcode"];
                    var formAnswers = dt.Rows[i]["formAnswers"];

                    innerItem = new ExpandoObject();
                    innerItem.location = location.ToString();
                    innerItem.bedno = regbedno.ToString();
                    innerItem.checkin_time = visitActualTime.ToString();
                    innerItem.exit_time = exitTime.ToString();
                    innerItem.temperature = temperature.ToString();
                    innerItem.nric = visitorNric.ToString();
                    innerItem.fullName = fullName.ToString();
                    innerItem.nationality = nationality.ToString();
                    innerItem.mobileTel = mobileTel.ToString();
                    innerItem.gender = gender.ToString();
                    innerItem.dob = dob.ToString();
                    innerItem.homeadd = homeadd.ToString();
                    innerItem.postalcode = postalcode.ToString();
                    innerItem.formAnswers = formAnswers.ToString();
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

        public String[] processBedNos(String[] bedno_arr)
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

        public String parseFormJson(String qa_json)
        {
            String sc_delim_ans = "";
            JObject form = JObject.Parse(qa_json);
            List<Object> formItems = form["Main"].ToList<Object>();

            foreach (Object formItem in formItems)
            {
                JObject item = JObject.FromObject(formItem);
                String question = (string)item["question"];
                String answer = (string)item["answer"];
                String itemString = question + ":" + answer + ";";
                sc_delim_ans = sc_delim_ans + itemString;
            }

            return sc_delim_ans;
        }

        public String fillDashboard(String query)
        {
            String[] queryParts = query.Split('~');

            String dash_startdate_str = queryParts[0];
            String dash_enddate_str = queryParts[1];

            DateTime dash_startdate = DateTime.ParseExact(dash_startdate_str, "yyyy-MM-dd", CultureInfo.InvariantCulture);
            DateTime dash_enddate = DateTime.ParseExact(dash_enddate_str, "yyyy-MM-dd", CultureInfo.InvariantCulture);

            String visitors_jsonstr = getVisitors(dash_startdate, dash_enddate);

            List<Object> processed_visitors_json_list = processVisitors(visitors_jsonstr);

            return Newtonsoft.Json.JsonConvert.SerializeObject(processed_visitors_json_list);
        }

        public List<Object> processVisitors(String visitors_jsonstr)
        {
            List<Object> processed_visitor_json_list = new List<Object>();

            JObject raw_visitors = JObject.Parse(visitors_jsonstr);
            JArray arr = (JArray)raw_visitors["Msg"];
            foreach (JToken item in arr.Children())
            {
                String visitor_str = item.Value<JObject>().ToString(Formatting.None);
                JObject visitor = JObject.Parse(visitor_str);
                dynamic innerItem = new ExpandoObject();

                //location from location/bedno
                string loc = "";
                string bedno = (string)visitor["bedno"];
                if (bedno.Length == 0)
                {
                    loc = (string)visitor["location"];
                }else
                {
                    if (bedno.Contains(','))
                    {
                        String[] bednos = bedno.Split(',');
                        loc = getLocFromBedno(bednos[0]); //if more than one registered bedno, use only the first one
                    }else
                    {
                        loc = getLocFromBedno(bedno);
                    }
                }
                innerItem.location = loc;

                //day of week, and hour of day from checkin_time
                string checkin_time_str = (string)visitor["checkin_time"];
                DateTime checkin_time = DateTime.ParseExact(checkin_time_str, "dd/MM/yyyy HH:mm:ss", CultureInfo.InvariantCulture);
                innerItem.dayOfWeek = checkin_time.ToString("ddd");
                innerItem.hourOfday = checkin_time.ToString("h tt");

                //dwelltime from checkin_time and exit_time
                string exit_time_str = (string)visitor["exit_time"];
                DateTime exit_time = DateTime.ParseExact(exit_time_str, "dd/MM/yyyy HH:mm:ss", CultureInfo.InvariantCulture);
                TimeSpan dwelltime_span = exit_time.Subtract(checkin_time);
                innerItem.dwelltime_min = Convert.ToInt32(dwelltime_span.TotalMinutes).ToString();

                innerItem.nric = visitor["nric"];
                innerItem.gender = visitor["gender"];

                //age from dob
                string birthday_str = (string)visitor["dob"];
                DateTime birthday = DateTime.ParseExact(birthday_str, "dd/MM/yyyy HH:mm:ss", CultureInfo.InvariantCulture);
                TimeSpan visitor_agespan = checkin_time.Subtract(birthday);
                double age_in_days = visitor_agespan.TotalDays;
                innerItem.age = Convert.ToInt32(age_in_days / 365.25);

                processed_visitor_json_list.Add(innerItem);
            }

            return processed_visitor_json_list;
        }

        public String getVisitors(DateTime startdatetime, DateTime enddatetime)
        {
            DataTable dt = new DataTable();
            dynamic json = new ExpandoObject();
            dynamic innerItem = new ExpandoObject();
            List<Object> jsonArray = new List<Object>();
            GenericProcedureDAO procedureCall = new GenericProcedureDAO("GET_VISITORS_BY_DATES", true, true, true);
            procedureCall.addParameter("@responseMessage", SqlDbType.Int);
            procedureCall.addParameterWithValue("@pStart_Date", startdatetime);
            procedureCall.addParameterWithValue("@pEnd_Date", enddatetime);
            try
            {
                ProcedureResponse resultss = procedureCall.runProcedure();
                dt = resultss.getDataTable();
                for (var i = 0; i < dt.Rows.Count; i++)
                {
                    var location = dt.Rows[i]["location"];
                    var regbedno = dt.Rows[i]["bedno"];
                    var visitActualTime = dt.Rows[i]["checkin_time"];
                    var exit_time = dt.Rows[i]["exit_time"];
                    var visitorNric = dt.Rows[i]["nric"];
                    var gender = dt.Rows[i]["gender"];
                    var dob = dt.Rows[i]["dob"];

                    innerItem = new ExpandoObject();
                    innerItem.location = location.ToString();
                    innerItem.bedno = regbedno.ToString();
                    innerItem.checkin_time = visitActualTime.ToString();
                    innerItem.exit_time = exit_time.ToString();
                    innerItem.nric = visitorNric.ToString();
                    innerItem.gender = gender.ToString();
                    innerItem.dob = dob.ToString();
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

        public String getLocFromBedno(String bedno)
        {
            String loc = "";
            DataTable dt = new DataTable();
            GenericProcedureDAO procedureCall = new GenericProcedureDAO("GET_LOC_BY_BEDNO", true, true, true);
            procedureCall.addParameter("@responseMessage", SqlDbType.Int);
            procedureCall.addParameterWithValue("@pBedno", bedno);
            try
            {
                ProcedureResponse resultss = procedureCall.runProcedure();
                dt = resultss.getDataTable();
                for (var i = 0; i < dt.Rows.Count; i++)
                {
                    loc = (string)dt.Rows[i]["location"];
                }
            }
            catch (Exception ex)
            {
                loc = "error: " + ex;
            }
            return loc;
        }
    }
}