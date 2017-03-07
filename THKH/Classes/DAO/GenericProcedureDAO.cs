using System;
using System.Collections;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Web;
using THKH.Classes.Entity;

namespace THKH.Classes.DAO
{
    public class GenericProcedureDAO 
    {
        Dictionary<String,String> parameters;
        Dictionary<String, ArrayList> responses;
        string procedureName;
        bool dataTableExpected;
        SqlParameter sqlparameter;

        /// <summary>
        /// Handles any procedure calls. This method will use the procedureName to call the sql procedure.
        /// sqlParametersWithValue is used to add parameters to the procedure give name of the parameters followed by the value of the parameter.
        /// SqlParamters is used to add sqlParameter which expects a response. If there is a response it will be returned via procedureResponse object.
        /// If dataTableExpected is true, it will return a datatable containing all of the rows returned by a query via procedureResponse, else will execute ExecuteNonQuery call.
        /// </summary>
        /// <param name="procedureName">Name of procedure to Execute</param>
        /// <param name="sqlParametersWithValues">If true, object expects sqlParameters with values</param>
        /// <param name="sqlParameters">If true, object expects sqlParameters with type</param>
        /// <param name="dataTableExpected">If true, dataTable will be available in returned object</param>
        public GenericProcedureDAO(string procedureName, bool sqlParametersWithValues,bool sqlParameters, bool dataTableExpected)
        {
            this.procedureName = procedureName;
            if(sqlParametersWithValues)
                this.parameters = new Dictionary<string, string>() ;
            this.dataTableExpected = dataTableExpected;
            if(sqlParameters)
                this.responses = new Dictionary<string, ArrayList>();
        }

        public ProcedureResponse runProcedure()
        {
            if (procedureName == null)
                throw new Exception("Class Not Initiated");

            ProcedureResponse toReturn = new ProcedureResponse();
            ArrayList responseObjectList = new ArrayList();

            SqlConnection cnn;
            cnn = new SqlConnection(System.Configuration.ConfigurationManager.ConnectionStrings["offlineConnection"].ConnectionString);

            if (responses != null)
            {
                foreach (var item in responses)
                {
                    ArrayList parameterTypeAndLength = item.Value;
                    if(parameterTypeAndLength.Count > 1)
                    {
                        sqlparameter = new SqlParameter(item.Key,(SqlDbType)parameterTypeAndLength[0],(int)parameterTypeAndLength[1]);
                    }
                    else
                    {
                        sqlparameter = new SqlParameter(item.Key, (SqlDbType)parameterTypeAndLength[0]);
                    }
                    
                    sqlparameter.Direction = ParameterDirection.Output;
                    responseObjectList.Add(sqlparameter);
                }
            }

            try
            {
                SqlCommand command = new SqlCommand("[dbo].["+procedureName+"]", cnn);
                command.CommandType = System.Data.CommandType.StoredProcedure;
                if(parameters != null)
                {
                    foreach (KeyValuePair<string,string> item in parameters)
                    {
                        command.Parameters.AddWithValue(item.Key, item.Value);
                    }
                }
                foreach(SqlParameter response in responseObjectList)
                {
                    command.Parameters.Add(response);
                }
               
                cnn.Open();

                if (dataTableExpected)
                {
                    SqlDataAdapter da = new SqlDataAdapter();
                    da.SelectCommand = command;
                    da.Fill(toReturn.getDataTable());
                }else
                {
                    command.ExecuteNonQuery();
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }finally
            {
                cnn.Close();
            }

            Dictionary<string, object> responseResult = toReturn.getResponses();
            foreach (SqlParameter response in responseObjectList)
            {
                if (response.Value != null)
                {
                    responseResult[response.ParameterName] = response.Value;
                }
            }

            return toReturn;
        }

        public void addParameterWithValue(string parameterName, string parameterValue)
        {
            parameters[parameterName] = parameterValue;
        }

        public void addParameter(string parameterName, SqlDbType type,int length = 0)
        {
            ArrayList parameterTypeAndLength = new ArrayList();
            parameterTypeAndLength.Add(type);
            if (length != 0)
                parameterTypeAndLength.Add(length);

            responses[parameterName] = parameterTypeAndLength;
        }
    }
}