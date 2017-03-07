using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace THKH.Classes.Entity
{
    public class Questionnaire
    {
        [JsonProperty] String qName;
        [JsonProperty] String qns;

        public Questionnaire(String qName, String qns)
        {
            this.qName = qName;
            this.qns = qns;
        }

        public String toJson()
        {
            return JsonConvert.SerializeObject(this);
        }

    }
}