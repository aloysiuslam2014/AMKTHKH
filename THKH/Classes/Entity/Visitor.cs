using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace THKH.Classes.Entity
{
    public class Visitor
    {

        String name;
        String nric;
        String gender;
        String nationality;
        String dob;
        String contactNum;
        String address;
        String postal;

        public Visitor(String name, String nric, String gender, String nationality, String dob, String contactNum, String address, String postal) {
            this.name = name;
            this.nric = nric;
            this.gender = gender;
            this.nationality = nationality;
            this.dob = dob;
            this.contactNum = contactNum;
            this.address = address;
            this.postal = postal;
        }

        public String toJson() {
            //dynamic vis = new ExpandoObject();
            //vis.Name = name;
            //vis.Nric = nric;
            //vis.Gender = gender;
            //vis.Nationality = nationality;
            //vis.Dob = dob;
            //vis.Contact = contactNum;
            //vis.Address = address;
            //vis.Postal = postal;
            return Newtonsoft.Json.JsonConvert.SerializeObject(this);
        }


    }
}