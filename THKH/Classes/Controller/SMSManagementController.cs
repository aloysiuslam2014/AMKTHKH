using System;
using System.Collections.Generic;
using System.Linq;
using THKH.Classes.DAO;
using THKH.Classes.Entity;
using Twilio;
using Twilio.Rest.Api.V2010.Account;
using Twilio.Types;

namespace THKH.Classes.Controller
{
    public class SMSManagementController
    {
        private GenericProcedureDAO procedureCall;

        /// <summary>
        /// Calls an API to send out SMSes given a string of numbers and a message
        /// </summary>
        /// <param name="message"></param>
        /// <param name="numbers"></param>
        /// <returns>JSON String</returns>
        public String sendSMS(String message, String numbers)
        {
            List<String> responses = new List<String>();
            string AccountSid = "AC9a49d86e66165ef9470571e0be7c892c";
            string AuthToken = "a750950b96a75c3ab36d4508bfd1db31";
            TwilioClient.Init(AccountSid, AuthToken);
            String[] numArr = numbers.Split(',');
            var distinctNumbersArrary = numArr.Distinct().ToArray();
            for (int i = 0; i < distinctNumbersArrary.Length; i++)
            {
                String number = distinctNumbersArrary[i];
                PhoneNumber to = null;
                if (number.Contains("+")) {
                    to = new PhoneNumber(number);
                } else if (number.Length == 8) {
                    to = new PhoneNumber("+65" + number);
                }

                if (to != null)
                {
                    try
                    {
                        var msg = MessageResource.Create(
                            to,
                            from: new PhoneNumber("+18324632876"),
                            body: message);

                        procedureCall = new GenericProcedureDAO("RECORD_SMS", true, true, false);
                        procedureCall.addParameter("@responseMessage", System.Data.SqlDbType.Int);
                        procedureCall.addParameterWithValue("@pSID", msg.Sid);
                        procedureCall.addParameterWithValue("@pContact", number);
                        procedureCall.addParameterWithValue("@pMessage", message);
                        ProcedureResponse responseOutput = procedureCall.runProcedure();

                        if (responseOutput.getSqlParameterValue("@responseMessage").ToString() == "0")
                        {
                            responses.Add(msg.Sid);
                        }
                    }
                    catch (Exception ex)
                    {
                        responses.Add(ex.Message);
                    }
                }
            }
            if (responses.Count() > 1)
            {
                return String.Join(",", responses);
            }
            return "Success";
        }

    }
}