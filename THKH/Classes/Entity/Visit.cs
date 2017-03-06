using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace THKH.Classes.Entity
{
    public class Visit
    {
        String visReqTime;
        String nric;
        String purpose;
        String otherPurpose;
        String visitLocation;
        String bedno;
        String qAid;
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
            return Newtonsoft.Json.JsonConvert.SerializeObject(this);
        }

    }
}