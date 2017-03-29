using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace THKH.Classes.Entity
{
    /// <summary>
    /// Stores a question's properties
    /// </summary>
    public class Question
    {
        [JsonProperty] String qn;
        [JsonProperty]
        String qnid;
        [JsonProperty] String qnType;
        [JsonProperty] String qnValues;
        [JsonProperty]
        String qnListID;

        public Question(String qnid, String qn, String qnType, String qnValues, String qnListID)
        {
            this.qnid = qnid;
            this.qn = qn;
            this.qnType = qnType;
            this.qnValues = qnValues;
            this.qnListID = qnListID;
        }

        public String toJson()
        {
            return JsonConvert.SerializeObject(this);
        }

        public dynamic toJsonObject()
        {
            return JsonConvert.DeserializeObject(toJson());
        }

        public String getId() {
            return qnid;
        }

    }
}