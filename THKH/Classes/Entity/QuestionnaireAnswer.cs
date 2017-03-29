using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace THKH.Classes.Entity
{
    /// <summary>
    /// Question Answer's properties
    /// </summary>
    public class QuestionnaireAnswer
    {
        [JsonProperty]
        List<dynamic> Main;

        public QuestionnaireAnswer(String qn)
        {
            dynamic obj = JsonConvert.DeserializeObject(qn);
            this.Main = obj.Main.ToObject<List<dynamic>>() ;
        }

        public String toJson()
        {
            return JsonConvert.SerializeObject(this);
        }

        public dynamic toJsonObject()
        {
            return JsonConvert.DeserializeObject(toJson());
        }

    }
}