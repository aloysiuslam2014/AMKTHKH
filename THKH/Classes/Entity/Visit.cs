﻿using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace THKH.Classes.Entity
{
    /// <summary>
    /// Visit object 
    /// </summary>
    public class Visit
    {
        [JsonProperty]
        String visReqTime;
        [JsonProperty]
        String nric;
        [JsonProperty]
        String purpose;
        [JsonProperty]
        String otherPurpose;
        [JsonProperty]
        String visitLocation;
        [JsonProperty]
        String bedno;
        [JsonProperty]
        String qAid;
        [JsonProperty]
        String remarks;

        public Visit(String visReqTime, String nric, String purpose, String otherPurpose, String visitLocation, String bedno, String qAid, String remarks)
        {
            this.visReqTime = visReqTime;
            this.nric = nric;
            this.purpose = purpose;
            this.otherPurpose = otherPurpose;
            this.visitLocation = visitLocation;
            this.bedno = bedno;
            this.qAid = qAid;
            this.remarks = remarks;
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