using System;
using System.Collections;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Web;

namespace THKH.Classes.Entity
{
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

        public DataTable getDataTable()
        {
            return this.generatedData;
        }

        public Dictionary<string, Object> getResponses()
        {
            return this.response;
        }

        public object getSqlParameterValue(String nameOfParam)
        {
            return this.response[nameOfParam];
        }

    }
}