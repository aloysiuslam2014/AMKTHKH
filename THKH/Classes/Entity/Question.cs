using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace THKH.Classes.Entity
{
    public class Question
    {
        String qn;
        String qnType;
        String qnValues;

        public Question(String qn, String qnType, String qnValues)
        {
            this.qn = qn;
            this.qnType = qnType;
            this.qnValues = qnValues;
        }

        public String toJson()
        {
            return Newtonsoft.Json.JsonConvert.SerializeObject(this);
        }

    }
}