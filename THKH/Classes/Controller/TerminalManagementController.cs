using System;
using System.Data;
using System.Linq;
using THKH.Classes.DAO;
using THKH.Classes.Entity;

namespace THKH.Classes.Controller
{
    public class TerminalManagementController
    {
        private GenericProcedureDAO procedureCall;
        private String toReturn = "";
        public String deleteAllTerminals(string id)
        {
            bool success = false;
            procedureCall = new GenericProcedureDAO("DELETE_ALL_TERMINAL", true, true, false);
            procedureCall.addParameter("@responseMessage", System.Data.SqlDbType.Int);
            try
            {
                ProcedureResponse responseOutput = procedureCall.runProcedure();
                success = responseOutput.getSqlParameterValue("@responseMessage").ToString().Equals("1") ? true : false;
            }
            catch (Exception ex)
            {

            }
            return success ? "true" : "false";
        }

        public String addTerminal(string id, String bedNoList, String infectious)
        {
            bool success = false;
            String formattedBedNoList = "";
            if (bedNoList.Contains('-'))
            {
                if (bedNoList.Contains(','))
                {
                    // Split by , then by - then increment
                    String[] bedranges = bedNoList.Split(',');
                    foreach (String s in bedranges)
                    {
                        String[] lowerUpperBedLimit = s.Split('-');
                        if (lowerUpperBedLimit.Length == 2)
                        {
                            int firstNumber = Int32.Parse(lowerUpperBedLimit[0]);
                            int secondNumber = Int32.Parse(lowerUpperBedLimit[1]);
                            if (firstNumber > secondNumber)
                            {
                                for (int i = secondNumber; i < firstNumber; i++)
                                {
                                    formattedBedNoList += i + ",";
                                }
                            }
                            else if (secondNumber > firstNumber)
                            {
                                for (int i = firstNumber; i < secondNumber; i++)
                                {
                                    formattedBedNoList += i + ",";
                                }
                            }
                            else
                            {
                                formattedBedNoList += firstNumber;
                            }
                        }
                        else
                        {
                            // Throw Format Exception
                        }
                    }
                }
                else
                {
                    // split by - then increment
                    String[] lowerUpperBedLimit = bedNoList.Split('-');
                    if (lowerUpperBedLimit.Length == 2)
                    {
                        int firstNumber = Int32.Parse(lowerUpperBedLimit[0]);
                        int secondNumber = Int32.Parse(lowerUpperBedLimit[1]);
                        if (firstNumber > secondNumber)
                        {
                            for (int i = secondNumber; i <= firstNumber; i++)
                            {
                                formattedBedNoList += i + ",";
                            }
                        }
                        else if (secondNumber > firstNumber)
                        {
                            for (int i = firstNumber; i <= secondNumber; i++)
                            {
                                formattedBedNoList += i + ",";
                            }
                        }
                        else
                        {
                            formattedBedNoList += firstNumber;
                        }
                    }
                    else
                    {
                        // Throw Format Exception
                    }
                }
            }
            else
            {
                formattedBedNoList = bedNoList;
            }

            procedureCall = new GenericProcedureDAO("ADD_TERMINAL", true, true, false);
            procedureCall.addParameter("@responseMessage", System.Data.SqlDbType.Int);
            procedureCall.addParameterWithValue("@pTName", id);
            procedureCall.addParameterWithValue("@pTControl", infectious);
            procedureCall.addParameterWithValue("@pBedNoList", formattedBedNoList);
            try
            {
                ProcedureResponse responseOutput = procedureCall.runProcedure();
                string respon = responseOutput.getSqlParameterValue("@responseMessage").ToString();
                success = respon.Equals("1") ? true : false;
            }
            catch (Exception ex)
            {
                var d = ex;//to read any errors
            }
            return success ? "true" : "false";
        }

        public String deleteTerminal(string id)
        {
            bool success = false;
            procedureCall = new GenericProcedureDAO("DELETE_TERMINAL", true, true, false);
            procedureCall.addParameter("@responseMessage", System.Data.SqlDbType.Int);
            procedureCall.addParameterWithValue("@pTerminal_ID", id);
            try
            {
                ProcedureResponse responseOutput = procedureCall.runProcedure();
                string respon = responseOutput.getSqlParameterValue("@responseMessage").ToString();
                success = respon.Equals("1") ? true : false;

            }
            catch (Exception ex)
            {
                var d = ex;//to read any errors
            }
            return success ? "true" : "false";
        }

        public String verify(String id)
        {
            bool success = false;
            procedureCall = new GenericProcedureDAO("VERIFY_STAFF", true, true, false);
            procedureCall.addParameter("@responseMessage", System.Data.SqlDbType.Int);
            procedureCall.addParameterWithValue("@pEmail", id);
            try
            {
                ProcedureResponse responseOutput = procedureCall.runProcedure();
                string respon = responseOutput.getSqlParameterValue("@responseMessage").ToString();
                success = respon.Equals("1") ? true : false;
            }
            catch (Exception ex)
            {
                var d = ex;//to read any errors
            }
            return success ? "true" : "false";
        }

        public String activateTerminal(String id)
        {
            bool success = false;
            int locationId = Convert.ToInt32(id);
            procedureCall = new GenericProcedureDAO("ACTIVATE_TERMINAL", true, true, true);
            procedureCall.addParameter("@responseMessage", System.Data.SqlDbType.Int);
            procedureCall.addParameterWithValue("@pTerminal_ID", id);
            try
            {
                ProcedureResponse responseOutput = procedureCall.runProcedure();
                string respon = responseOutput.getSqlParameterValue("@responseMessage").ToString();
                success = respon.Equals("1") ? true : false;
            }
            catch (Exception ex)
            {
                var a = ex;
            }
            return success ? "true" : "false";
        }

        public String deactivateTerminal(String id)
        {
            bool success = false;
            int locationId = Convert.ToInt32(id);
            procedureCall = new GenericProcedureDAO("DEACTIVATE_TERMINAL", true, true, false);
            procedureCall.addParameter("@responseMessage", System.Data.SqlDbType.Int);
            procedureCall.addParameterWithValue("@pTerminal_ID", id);

            try
            {
                ProcedureResponse responseOutput = procedureCall.runProcedure();
                string respon = responseOutput.getSqlParameterValue("@responseMessage").ToString();
                success = respon.Equals("1") ? true : false;
            }
            catch (Exception ex)
            {

            }
            return success ? "true" : "false";
        }

        public String deactivateAllTerminal(String id)
        {
            bool success = false;
            int locationId = Convert.ToInt32(id);
            procedureCall = new GenericProcedureDAO("DEACTIVATE_ALL_TERMINALS", true, true, false);
            procedureCall.addParameter("@responseMessage", System.Data.SqlDbType.Int);
            try
            {
                ProcedureResponse responseOutput = procedureCall.runProcedure();
                string respon = responseOutput.getSqlParameterValue("@responseMessage").ToString();
                success = respon.Equals("1") ? true : false;

            }
            catch (Exception ex)
            {

            }
            return success ? "true" : "false";

        }

        public String  checkInUser(String locationId, String userId)
        {
            bool success = false;
            int id = Convert.ToInt32(locationId);
            procedureCall = new GenericProcedureDAO("CREATE_MOVEMENT", true, true, false);
            procedureCall.addParameter("@responseMessage", System.Data.SqlDbType.Int);
            procedureCall.addParameterWithValue("@pLocationId", locationId);
            procedureCall.addParameterWithValue("@pNRIC", userId);
            try
            {

                ProcedureResponse responseOutput = procedureCall.runProcedure();
                string respon = responseOutput.getSqlParameterValue("@responseMessage").ToString();
                success = respon.Equals("1") || respon.Equals("2") ? true : false;
                if (success) {
                    toReturn = "success";
                }
                else if (respon.Equals("2"))
                {
                    toReturn = "success,locationError";
                }
                else if (respon.Equals("3"))
                {
                    toReturn = "success,noCheckIn";
                }
            }
            catch (Exception ex)
            {
                var test = ex;
            }
            return success ? toReturn : "false";
        }

        public String getAllTerminals()
        {

            DataTable dataTable = new DataTable();
            procedureCall = new GenericProcedureDAO("GET_ALL_TERMINALS", true, true, true);
            try
            {
                ProcedureResponse responseOutput = procedureCall.runProcedure();
                dataTable = responseOutput.getDataTable();
            }
            catch (Exception ex)
            {

            }

            toReturn = "";
            for (var i = 0; i < dataTable.Rows.Count; i++)
            {
                String placeName = dataTable.Rows[i]["tName"].ToString();
                String id = dataTable.Rows[i]["terminalID"].ToString();
                String activated = dataTable.Rows[i]["activated"].ToString();
                toReturn += id + "," + placeName + "," + activated + "|";
            }

            return toReturn;
        }

    }
}