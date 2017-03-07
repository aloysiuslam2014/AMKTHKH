using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace THKH.Classes.Entity
{
    public class Question
    {
        [JsonProperty] String qn;
        [JsonProperty] String qnType;
        [JsonProperty] String qnValues;

        public Question(String qn, String qnType, String qnValues)
        {
            this.qn = qn;
            this.qnType = qnType;
            this.qnValues = qnValues;
        }

        public String toJson()
        {
            return JsonConvert.SerializeObject(this);
        }

    }
}