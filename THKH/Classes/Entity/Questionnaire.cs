using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace THKH.Classes.Entity
{
    public class Questionnaire
    {
        String qName;
        String qns;

        public Questionnaire(String qName, String qns)
        {
            this.qName = qName;
            this.qns = qns;
        }

        public String toJson()
        {
            return Newtonsoft.Json.JsonConvert.SerializeObject(this);
        }

    }
}