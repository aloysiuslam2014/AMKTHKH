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

        /// <summary>
        /// The main method for contact tracing of express entry visitors
        /// </summary>
        /// <param name="query">Tilde-delimited string, with the first term being the start date(inclusive) of the query in "yyyy-MM-dd" format, and the second term being the end date(inclusive) of the query in "yyyy-MM-dd" format</param>
        /// <returns>A JSON object, containing the attribute Msg, which is a JSON array of data each representing one visit, formatted for DataTable to process, in the form: [location, bedno, checkin_time, exit_time, temperature, fullName, nric, gender, date_of_birth, mobileTel, homeAdd, postalcode, nationality, formAnswers, registered?, scanned?]</returns>
        public String expressTrace(String query)
        {
            String result = "";

            String[] queryParts = query.Split('~');
            String uq_startdate_str = queryParts[0];
            String uq_enddate_str = queryParts[1];
            DateTime uq_startdate = DateTime.ParseExact(uq_startdate_str, "yyyy-MM-dd", CultureInfo.InvariantCulture);
            DateTime uq_enddate = DateTime.ParseExact(uq_enddate_str, "yyyy-MM-dd", CultureInfo.InvariantCulture);

            dynamic json = new ExpandoObject();
            dynamic innerItem = new ExpandoObject();
            List<String> resultList = new List<String>();

            String expressResult = traceByExpress(uq_startdate, uq_enddate);
            if (expressResult != "")
            {
                JObject obj = JObject.Parse(expressResult);
                JArray arr = (JArray)obj["Msg"];
                foreach (JToken item in arr.Children())
                {
                    String entry = item.Value<JObject>().ToString(Formatting.None);
                    resultList.Add(entry);
                }
            }
            List<Tuple<List<String>, bool, bool>> categorizedResults = new List<Tuple<List<String>, bool, bool>>();
            categorizedResults.Add(new Tuple<List<String>, bool, bool>(resultList, true, true));
            result = buildDisplayResults(categorizedResults);

            return result;
        }


        /// <summary>
        /// Main method for the contact tracing process
        /// </summary>
        /// <param name="query">Tilde-delimited string, with the first term being either "bybed" or "byloc", the second term being the start date(inclusive) of the query in "yyyy-MM-dd" format, the third term being the end date(inclusive) of the query in "yyyy-MM-dd" format, and the fourth term being either a comma-delimited and/or hypenated range of bed numbers, or a comma-delimited string of locations</param>
        /// <returns>A JSON object, containing the attribute Msg, which is a JSON array of data each representing one visit, formatted for DataTable to process, in the form: [location, bedno, checkin_time, exit_time, temperature, fullName, nric, gender, date_of_birth, mobileTel, homeAdd, postalcode, nationality, formAnswers, registered?, scanned?]</returns>
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
            //categorizedResults.Add(new Tuple<List<String>, bool, bool>(scan_only, false, true));

            result = buildDisplayResults(categorizedResults);

            return result;
        }

        
        /// <summary>
        /// Convert contact tracing results into a form acceptable by DataTables
        /// </summary>
        /// <param name="categorizedResults">A List of Tuples, each Tule being: A List of JSON strings, each corresponding to a visit; a boolean corresponding to whether or not the visitor registered to visit the bed/location queried; a boolean corresponding to whether or not the visitor scanned their pass at the bed/location queried</param>
        /// <returns>A JSON string in the DataTable format</returns>
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


        /// <summary>
        /// Trace visitors who scanned their visitor pass at the terminal the patient's bed is assigned to 
        /// </summary>
        /// <param name="startdatetime">Start of tracing period(inclusive)</param>
        /// <param name="enddatetime">End of tracing period(inclusive)</param>
        /// <param name="bedno">4-digit bed number as a String</param>
        /// <returns>If successful, a JSON object with an attribute Msg containing the attributes: location, bedno, checkin_time, exit_time, temperature, fullName, nric, gender, date_of_birth, mobileTel, homeAdd, postalcode, nationality, formAnswers, registered?, scanned?; if unsuccessful, a JSON object with the attribute Msg containing the database access exception</returns>
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


        /// <summary>
        /// Trace visitors who indicated at check-in registration that they would be visiting a patient's bed  
        /// </summary>
        /// <param name="startdatetime">Start of tracing period(inclusive)</param>
        /// <param name="enddatetime">End of tracing period(inclusive)</param>
        /// <param name="bedno">4-digit bed number as a String</param>
        /// <returns>If successful, a JSON object with an attribute Msg containing the attributes: location, bedno, checkin_time, exit_time, temperature, fullName, nric, gender, date_of_birth, mobileTel, homeAdd, postalcode, nationality, formAnswers, registered?, scanned?; if unsuccessful, a JSON object with the attribute Msg containing the database access exception</returns>
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

        //
        /// <summary>
        /// Trace visitors who used Express Check-in
        /// </summary>
        /// <param name="startdatetime">Start of tracing period(inclusive)</param>
        /// <param name="enddatetime">End of tracing period(inclusive)</param>
        /// <returns>If successful, a JSON object with an attribute Msg containing the attributes: location, bedno, checkin_time, exit_time, temperature, fullName, nric, gender, date_of_birth, mobileTel, homeAdd, postalcode, nationality, formAnswers; if unsuccessful, a JSON object with the attribute Msg containing the database access exception</returns>
        public String traceByExpress(DateTime startdatetime, DateTime enddatetime)
        {
            DataTable dt = new DataTable();
            dynamic json = new ExpandoObject();
            dynamic innerItem = new ExpandoObject();
            List<Object> jsonArray = new List<Object>();
            GenericProcedureDAO procedureCall = new GenericProcedureDAO("TRACE_BY_EXPRESS_ENTRY", true, true, true);
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


        /// <summary>
        /// Trace visitors who scanned their visitor pass at a terminal that has no beds assigned to it
        /// </summary>
        /// <param name="startdatetime">Start of tracing period(inclusive)</param>
        /// <param name="enddatetime">End of tracing period(inclusive)</param>
        /// <param name="loc">A terminal name, or substring of a terminal name</param>
        /// <returns>If successful, a JSON object with an attribute Msg containing the attributes: location, bedno, checkin_time, exit_time, temperature, fullName, nric, gender, date_of_birth, mobileTel, homeAdd, postalcode, nationality, formAnswers, registered?, scanned?; if unsuccessful, a JSON object with the attribute Msg containing the database access exception</returns>
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


        /// <summary>
        /// Trace visitors who indicated at check-in registration that they would be visiting a location that has no beds assigned to it
        /// </summary>
        /// <param name="startdatetime">Start of tracing period(inclusive)</param>
        /// <param name="enddatetime">End of tracing period(inclusive)</param>
        /// <param name="loc">A terminal name, or substring of a terminal name</param>
        /// <returns>If successful, a JSON object with an attribute Msg containing the attributes: location, bedno, checkin_time, exit_time, temperature, fullName, nric, gender, date_of_birth, mobileTel, homeAdd, postalcode, nationality, formAnswers, registered?, scanned?; if unsuccessful, a JSON object with the attribute Msg containing the database access exception</returns>
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

        /// <summary>
        /// Converts an array of beds containing hypenated bed number ranges, to one containing only bed numbers
        /// </summary>
        /// <param name="bedno_arr">An array of bed numbers that might contain hypenated bed number ranges, e.g. ["1101", "1103", "1107-1112", "1121"]</param>
        /// <returns>An array of bed numbers, e.g. ["1101", "1103", "1107", "1108", "1109", "1110", "1111", "1112", "1121"]</returns>
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

        /// <summary>
        /// Converts screening form answers from JSON object to a semicolon delimited string of question:answer pairs.
        /// </summary>
        /// <param name="qa_json">JSON string of visitor registration questionnaire questions and answers</param>
        /// <returns>Semicolon delimited string of question:answer pairs, e.g. "Did you travel overseas in the last 2 weeks?:Yes;Have you had a fever in the past 3 days?:No"</returns>
        public String parseFormJson(String qa_json)
        {
            String sc_delim_ans = "";
            try
            {
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
            }
            catch (Exception ex) {}
            return sc_delim_ans;
        }

        /// <summary>
        /// Main method for the visitor data visualization dashboard
        /// </summary>
        /// <param name="query">Tilde-delimited string, with the first term being the start date(inclusive) of the query in "yyyy-MM-dd" format, and the second term being the end date(inclusive) of the query in "yyyy-MM-dd" format</param>
        /// <returns>JSON array of JSON arrays, each inner array corresponding to the data set for a CanvasJS chart</returns>
        public String fillDashboard(String query)
        {
            String[] queryParts = query.Split('~');

            String dash_startdate_str = queryParts[0];
            String dash_enddate_str = queryParts[1];

            DateTime dash_startdate = DateTime.ParseExact(dash_startdate_str, "yyyy-MM-dd", CultureInfo.InvariantCulture);
            DateTime dash_enddate = DateTime.ParseExact(dash_enddate_str, "yyyy-MM-dd", CultureInfo.InvariantCulture);

            String visitors_jsonstr = getVisitors(dash_startdate, dash_enddate);

            List<Object> processed_visitors_json_list = processVisitors(visitors_jsonstr);

            List<String> compiled_visitor_data_list = compileVisitorData(processed_visitors_json_list); //conver transactional data to grouped data

            List<List<Object>> canvasjs_converted_data_list = canvasjs_convert(compiled_visitor_data_list);

            String result = Newtonsoft.Json.JsonConvert.SerializeObject(canvasjs_converted_data_list);

            return result;
        }

        /// <summary>
        /// Convert dictionary-like aggregated chart data into a format that CanvasJS accepts
        /// </summary>
        /// <param name="compiled_visitor_json_data_list">A List of JSON strings, each corresponding to a chart, containing the attributes for each category/bin, with values containing the count of visitors in each category/bin</param>
        /// <returns>A List of Lists, each inner list corresponding to a CanvasJS chart, containing JSON objects corresponding to one data point on the CanvasJS chart.</returns>
        public List<List<Object>> canvasjs_convert(List<String> compiled_visitor_json_data_list)
        {
            List<List<Object>> canvasjs_json_data_list = new List<List<Object>>();

            string dayOfWeek_json_str = compiled_visitor_json_data_list[0];
            dynamic dayOfWeek_json = JsonConvert.DeserializeObject(dayOfWeek_json_str);
            List<Object> canvasjs_dayOfWeek_list = new List<Object>();
            List<string> daysOfWeek = new List<string>(new string[] { "Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun" });
            foreach (String day in daysOfWeek)
            {
                dynamic canvas_dataItem = new ExpandoObject();
                canvas_dataItem.label = day;
                canvas_dataItem.y = (int)(dayOfWeek_json)[day];
                canvasjs_dayOfWeek_list.Add(canvas_dataItem);
            }

            string hourOfDay_json_str = compiled_visitor_json_data_list[1];
            dynamic hourOfDay_json = JsonConvert.DeserializeObject(hourOfDay_json_str);
            List<Object> canvasjs_hourOfday_list = new List<Object>();
            List<string> hoursOfDay = new List<string>(new string[] { "0 AM", "1 AM", "2 AM", "3 AM", "4 AM", "5 AM", "6 AM", "7 AM", "8 AM", "9 AM", "10 AM", "11 AM", "12 PM", "1 PM", "2 PM", "3 PM", "4 PM", "5 PM", "6 PM", "7 PM", "8 PM", "9 PM", "10 PM", "11 PM" });
            foreach (String hour in hoursOfDay)
            {
                dynamic canvas_dataItem = new ExpandoObject();
                canvas_dataItem.label = hour;
                canvas_dataItem.y = (int)(hourOfDay_json)[hour];
                canvasjs_hourOfday_list.Add(canvas_dataItem);
            }

            string dwelltime_json_str = compiled_visitor_json_data_list[2];
            dynamic dwelltime_json = JsonConvert.DeserializeObject(dwelltime_json_str);
            List<Object> canvasjs_dwelltime_list = new List<Object>();
            List<string> dwelltimes = new List<string>(new string[] { "<30m", "31-60m", "61-90m", "91-120m", "121-150m", "151-180m", "181-210m", "211-240m", "241-270m", "271-300m", "301-330m", "331-360m", ">360m" });
            for (int i = 1; i<dwelltimes.Count; i++)
            {
                dynamic canvas_dataItem = new ExpandoObject();
                string label = dwelltimes[i - 1];
                //canvas_dataItem.x = (int)(i * 10);
                canvas_dataItem.y = (int)(dwelltime_json)[label];
                canvas_dataItem.label = label;
                canvasjs_dwelltime_list.Add(canvas_dataItem);
            }

            string gender_json_str = compiled_visitor_json_data_list[3];
            dynamic gender_json = JsonConvert.DeserializeObject(gender_json_str);
            List<Object> canvasjs_gender_list = new List<Object>();
            List<string> genders = new List<string>(new string[] { "M", "F" });
            for (int i = 1; i <= genders.Count; i++)
            {
                dynamic canvas_dataItem = new ExpandoObject();
                string label = genders[i - 1];
                //canvas_dataItem.x = (int)(i * 10);
                canvas_dataItem.y = (int)(gender_json)[label];
                canvas_dataItem.label = label;
                canvasjs_gender_list.Add(canvas_dataItem);
            }

            string age_json_str = compiled_visitor_json_data_list[4];
            dynamic age_json = JsonConvert.DeserializeObject(age_json_str);
            List<Object> canvasjs_age_list = new List<Object>();
            List<string> ages = new List<string>(new string[] { "<10y", "11-20y", "21-30y", "31-40y", "31-40y", "41-50y", "51-60y", "61-70y", "71-80y", "81-90y", ">90y" });
            for (int i = 1; i < ages.Count; i++)
            {
                dynamic canvas_dataItem = new ExpandoObject();
                string label = ages[i - 1];
                //canvas_dataItem.x = (int)(i * 10);
                canvas_dataItem.y = (int)(age_json)[label];
                canvas_dataItem.label = label;
                canvasjs_age_list.Add(canvas_dataItem);
            }

            string location_json_str = compiled_visitor_json_data_list[5];
            dynamic location_json = JsonConvert.DeserializeObject<Dictionary<string, dynamic>>(location_json_str);
          //  var k= location_json.Keys();
            List<Object> canvasjs_location_list = new List<Object>();
            foreach (var loc in location_json.Keys)
            {
                dynamic canvas_dataItem = new ExpandoObject();
                canvas_dataItem.label = (string)loc;
                canvas_dataItem.y = (int)location_json[loc];
                canvasjs_location_list.Add(canvas_dataItem);
            }

            canvasjs_json_data_list.Add(canvasjs_dayOfWeek_list);
            canvasjs_json_data_list.Add(canvasjs_hourOfday_list);
            canvasjs_json_data_list.Add(canvasjs_dwelltime_list);
            canvasjs_json_data_list.Add(canvasjs_gender_list);
            canvasjs_json_data_list.Add(canvasjs_age_list);
            canvasjs_json_data_list.Add(canvasjs_location_list);

            return canvasjs_json_data_list;
        }

        /// <summary>
        /// Conversion of transactional visit data into aggregated data, based on bins if necessary
        /// </summary>
        /// <param name="visitors_json_list">A List of JSON objects representing visits, each only containing the attributes needed to engineer the parameters to be visualized.</param>
        /// <returns>A List of JSON strings, each corresponding to a chart, containing the attributes for each category/bin, with values containing the count of visitors in each category/bin</returns>
        public List<String> compileVisitorData(List<Object> visitors_json_list)
        {
            List<String> datajson_list = new List<String>();

            String dayOfWeek_json_str = "{}";
            String hourOfDay_json_str = "{}";
            String dwelltime_json_str = "{}";
            String gender_json_str = "{}";
            String age_json_str = "{}";
            String location_json_str = "{}";

            dynamic dayOfWeek_json = new ExpandoObject();
            List<string> daysOfWeek = new List<string>(new string[] { "Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun" });
            foreach(String day in daysOfWeek)
            {
                ((IDictionary<string, object>)dayOfWeek_json)[day] = 0;
            }
            dynamic hourOfDay_json = new ExpandoObject();
            List<string> hoursOfDay = new List<string>(new string[] { "0 AM", "1 AM", "2 AM", "3 AM", "4 AM", "5 AM", "6 AM", "7 AM", "8 AM", "9 AM", "10 AM", "11 AM", "12 PM", "1 PM", "2 PM", "3 PM", "4 PM", "5 PM", "6 PM", "7 PM", "8 PM", "9 PM", "10 PM", "11 PM"});
            foreach (String hour in hoursOfDay)
            {
                ((IDictionary<string, object>)hourOfDay_json)[hour] = 0;
            }
            dynamic dwelltime_json = new ExpandoObject();
            List<string> dwelltimes = new List<string>(new string[] { "<30m", "31-60m", "61-90m", "91-120m", "121-150m", "151-180m", "181-210m", "211-240m", "241-270m", "271-300m", "301-330m", "331-360m", ">360m" });
            foreach (String dwelltime_bucket in dwelltimes)
            {
                ((IDictionary<string, object>)dwelltime_json)[dwelltime_bucket] = 0;
            }
            dynamic gender_json = new ExpandoObject();
            List<string> genders = new List<string>(new string[] { "M", "F"});
            foreach (String gender in genders)
            {
                ((IDictionary<string, object>)gender_json)[gender] = 0;
            }
            dynamic age_json = new ExpandoObject();
            List<string> ages = new List<string>(new string[] { "<10y", "11-20y", "21-30y", "31-40y", "31-40y", "41-50y", "51-60y", "61-70y", "71-80y", "81-90y",">90y" });
            foreach (String age_bucket in ages)
            {
                ((IDictionary<string, object>)age_json)[age_bucket] = 0;
            }

            dynamic location_json = new ExpandoObject();

            //update counts
            foreach (dynamic visitor in visitors_json_list)
            {
                string visitor_dayOfweek = (string)visitor.dayOfWeek;
                ((IDictionary<string, object>)dayOfWeek_json)[visitor_dayOfweek] = (int)((IDictionary<string, object>)dayOfWeek_json)[visitor_dayOfweek] + 1;
                string visitor_hourOfDay = (string)visitor.hourOfDay;
                ((IDictionary<string, object>)hourOfDay_json)[visitor_hourOfDay] = (int)((IDictionary<string, object>)hourOfDay_json)[visitor_hourOfDay] + 1;
                int visitor_dwelltime = Int32.Parse((string)visitor.dwelltime_min);
                int visitor_dwelltime_floor = (int)(Math.Floor((double)visitor_dwelltime / 30) * 30) + 1 ; //28m return 0, 31m returns 30
                int visitor_dwelltime_ceiling = visitor_dwelltime_floor + 30 - 1;
                string visitor_dwelltime_bucket = "<30m";
                if (visitor_dwelltime > 360)
                {
                    visitor_dwelltime_bucket = ">360m";
                }else if (visitor_dwelltime > 30)
                {
                    visitor_dwelltime_bucket = visitor_dwelltime_floor.ToString() + "-" + visitor_dwelltime_ceiling.ToString() + "m";
                }
                ((IDictionary<string, object>)dwelltime_json)[visitor_dwelltime_bucket] = (int)((IDictionary<string, object>)dwelltime_json)[visitor_dwelltime_bucket] + 1;
                string visitor_gender = ((string)visitor.gender).Trim();
                ((IDictionary<string, object>)gender_json)[visitor_gender] = (int)((IDictionary<string, object>)gender_json)[visitor_gender] + 1;
                int visitor_age = (int)visitor.age;
                if (visitor_age % 10 == 0) //if visitor age is multiple of 10 we need to move them down by one bin
                {
                    visitor_age = visitor_age - 1;
                }
                int visitor_age_floor = (int)(Math.Floor((double)visitor_age / 10) * 10) + 1; //19 return 10, 21 returns 20
                int visitor_age_ceiling = visitor_age_floor + 10 - 1;
                string visitor_age_bucket = "<10y";
                if (visitor_age > 90)
                {
                    visitor_age_bucket = ">90y";
                }
                else if (visitor_age > 10)
                {
                    visitor_age_bucket = visitor_age_floor.ToString() + "-" + visitor_age_ceiling.ToString() + "y";
                }
                ((IDictionary<string, object>)age_json)[visitor_age_bucket] = (int)((IDictionary<string, object>)age_json)[visitor_age_bucket] + 1;

                string visitor_location = ((string)visitor.location).Trim();
                if (((IDictionary<string, object>)location_json).ContainsKey(visitor_location))
                {
                    ((IDictionary<string, object>)location_json)[visitor_location] = (int)((IDictionary<string, object>)location_json)[visitor_location] + 1;
                }
                else
                {
                    ((IDictionary<string, object>)location_json)[visitor_location] = 1;
                }
            }

            dayOfWeek_json_str = Newtonsoft.Json.JsonConvert.SerializeObject(dayOfWeek_json);
            hourOfDay_json_str = Newtonsoft.Json.JsonConvert.SerializeObject(hourOfDay_json);
            dwelltime_json_str = Newtonsoft.Json.JsonConvert.SerializeObject(dwelltime_json);
            gender_json_str = Newtonsoft.Json.JsonConvert.SerializeObject(gender_json);
            age_json_str = Newtonsoft.Json.JsonConvert.SerializeObject(age_json);
            location_json_str = Newtonsoft.Json.JsonConvert.SerializeObject(location_json);


            datajson_list.Add(dayOfWeek_json_str);
            datajson_list.Add(hourOfDay_json_str);
            datajson_list.Add(dwelltime_json_str);
            datajson_list.Add(gender_json_str);
            datajson_list.Add(age_json_str);
            datajson_list.Add(location_json_str);
            return datajson_list;
        }

        /// <summary>
        /// Retrieve visitor information available on database needed to engineer data to be visualized
        /// </summary>
        /// <param name="visitors_jsonstr">A JSON string with an attribute Msg containing a list of JSON objects, each representing a visitor, with the attributes: location, bedno, checkin_time, exit_time, temperature, fullName, nric, gender, date_of_birth, mobileTel, homeAdd, postalcode, nationality, formAnswers, registered?, scanned? </param>
        /// <returns>A List of JSON objects representing visits, each only containing the attributes needed to engineer the parameters to be visualized.</returns>
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
                    if (loc.Length == 0)
                    {
                        loc = "No location or bed provided";
                    }
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
                innerItem.hourOfDay = checkin_time.ToString("h tt");

                //dwelltime from checkin_time and exit_time
                string exit_time_str = (string)visitor["exit_time"];
                if(exit_time_str.Length == 0)
                {
                    exit_time_str = checkin_time_str;
                }
                DateTime exit_time = DateTime.ParseExact(exit_time_str, "dd/MM/yyyy HH:mm:ss", CultureInfo.InvariantCulture);
                TimeSpan dwelltime_span = exit_time.Subtract(checkin_time);
                innerItem.dwelltime_min = Convert.ToInt32(dwelltime_span.TotalMinutes).ToString();

                innerItem.nric = (string)visitor["nric"];
                innerItem.gender = (string)visitor["gender"];

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

        /// <summary>
        /// Get all visitors within a time frame
        /// </summary>
        /// <param name="startdatetime">Start of tracing period(inclusive)</param>
        /// <param name="enddatetime">End of tracing period(inclusive)</param>
        /// <returns>If successful, a JSON string with an attribute Msg containing a list of JSON objects, each representing a visitor, with the attributes: location, bedno, checkin_time, exit_time, temperature, fullName, nric, gender, date_of_birth, mobileTel, homeAdd, postalcode, nationality, formAnswers, registered?, scanned?; if unsuccessful, a JSON object with the attribute Msg containing the database access exception</returns>
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

                    bool noloc = location.ToString().Length == 0 & regbedno.ToString().Length == 0;

                    if (gender.ToString().Trim().Length > 0 && !noloc) //check that the visitor is not an express entry visitor
                    {
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

        /// <summary>
        /// Convert bed number to corresponding terminal name
        /// </summary>
        /// <param name="bedno">4-digit bed number as a String</param>
        /// <returns>Terminal name corresponding to the bed number</returns>
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
                //for (var i = 0; i < dt.Rows.Count; i++)
                //{
                    loc = (string)dt.Rows[0]["location"];
                //}
            }
            catch (Exception ex)
            {
                loc = "Unassigned bed number";
            }
            return loc;
        }
    }
}