using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace THKH.Classes.Entity
{
    public class StaffUser
    {
        [JsonProperty]
        String firstName;
        [JsonProperty]
        String lastName;
        [JsonProperty]
        String nric;
        [JsonProperty]
        String sex;
        [JsonProperty]
        String nationality;
        [JsonProperty]
        String dateOfBirth;
        [JsonProperty]
        String mobTel;
        [JsonProperty]
        String address;
        [JsonProperty]
        int postalCode;
        [JsonProperty]
        String email;
        [JsonProperty]
        String homeTel;
        [JsonProperty]
        String altTel;
        [JsonProperty]
        int permissions;
        [JsonProperty]
        String accessProfile;
        [JsonProperty]
        String position;

        public StaffUser(String firstName, String lastName, String nric, String sex, String nationality, String dateOfBirth, String mobTel, String address, int postalCode, 
            String email, String homeTel, String altTel, int permissions, String accessProfile, String position)
        {
            this.firstName = firstName;
            this.lastName = lastName;
            this.nric = nric;
            this.sex = sex;
            this.nationality = nationality;
            this.dateOfBirth = dateOfBirth;
            this.mobTel = mobTel;
            this.address = address;
            this.email = email;
            this.homeTel = homeTel;
            this.altTel = altTel;
            this.permissions = permissions;
            this.accessProfile = accessProfile;
            this.position = position;
            this.postalCode = postalCode;
        }

        public String toJson()
        {
            //dynamic vis = new ExpandoObject();
            //vis.Name = name;
            //vis.Nric = nric;
            //vis.Gender = gender;
            //vis.Nationality = nationality;
            //vis.Dob = dob;
            //vis.Contact = contactNum;
            //vis.Address = address;
            //vis.Postal = postal;
            return JsonConvert.SerializeObject(this);
        }

        public dynamic toJsonObject()
        {
            //dynamic vis = new ExpandoObject();
            //vis.Name = name;
            //vis.Nric = nric;
            //vis.Gender = gender;
            //vis.Nationality = nationality;
            //vis.Dob = dob;
            //vis.Contact = contactNum;
            //vis.Address = address;
            //vis.Postal = postal;
            return JsonConvert.DeserializeObject(toJson());
        }
    }
}