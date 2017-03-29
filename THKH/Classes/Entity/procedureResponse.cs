using System;
using System.Collections;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Web;

namespace THKH.Classes.Entity
{
    /// <summary>
    /// Response output recieved from running the procedure. 
    /// </summary>
    public class ProcedureResponse
    {
        DataTable generatedData;
        Dictionary<string, Object> response;
        SqlParameter parameter;

        public ProcedureResponse()
        {
            generatedData = new DataTable();
            response = new Dictionary<string, Object>();
            parameter = new SqlParameter();
        }

        /// <summary>
        /// Gets the table generated from a procedure
        /// </summary>
        /// <returns></returns>
        public DataTable getDataTable()
        {
            return this.generatedData;
        }

        /// <summary>
        /// Gets all the return parameters from a procedure if there is any
        /// </summary>
        /// <returns>Dictionary of Parameter name and it's value</returns>
        public Dictionary<string, Object> getResponses()
        {
            return this.response;
        }

        /// <summary>
        /// Gets a specific parameter's value
        /// </summary>
        /// <param name="nameOfParam">Parameter name to get back</param>
        /// <returns>Value of parameter object (May be int or varchar etc.)</returns>
        public object getSqlParameterValue(String nameOfParam)
        {
            return this.response[nameOfParam];
        }

    }
}