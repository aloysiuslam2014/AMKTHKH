/// <reference path="registrationPageScripts.js" />
$(document).ready(function () {
    
    // ajax call here
});

function callCheck (){
    //Do ajax call
    var nricValue = nric.value;
    var msg;
    var headersToProcess = { nric: nricValue, requestType: "getdetails" }; //Store objects in this manner 
    $.ajax({
        url: './CheckInOut/checkIn.ashx',
        method: 'post',
        data: headersToProcess,
        
        
        success: function (returner) {
            var resultOfGeneration = JSON.parse(returner);
            if (resultOfGeneration.Result === "Success") {
                // ASHX returns all the visitor information
                // Populate fields if visitor exists by spliting string into array of values & populating
                var string = resultOfGeneration.Msg;
                var arr = string.split(",");
                var dateString = arr[4].replace(/-/g, "/").toString() + " 0:01 AM";
                $("#nric").attr('value', arr[0]);
                $("#namesInput").attr('value', arr[1]);
                $("#sexinput").attr('value', arr[2]);
                $("#nationalsInput").attr('value', arr[3]);
                $("#daterange").attr('value', dateString);
                $("#addresssInput").attr('value', arr[10]);
                $("#postalsInput").attr('value', arr[11]);
                $("#mobilesInput").attr('value', arr[6]);
                $("#altInput").attr('value', arr[8]);
                $("#homesInput").attr('value', arr[7]);
                $("#emailsInput").attr('value', arr[9]);
                $("#visitbookingtime").attr('value', arr[13]);
                $("#patientNric").attr('value', arr[14]);
                $("#patientName").attr('value', arr[16]);
                $("#pInput").attr('value', arr[17]);
                $("#purposeInput").attr('value', arr[18]);
                $("#visLoc").attr('value', arr[19]);
            } else {
                alert("Error: " + resultOfGeneration.Msg);
            }
        },
        error: function (err) {
            alert(err.Msg);
        },
    });
    dataFound = true;
}

function checkTemp() { // Rewrite to actively check
    var temper = temp.value;
    if (parseFloat(temper) > 37.6) { //Check if temperature exists & meets criteria
        $('#tempWarning').css("display", "block");
    } else {
        $('#tempWarning').css("display", "none");
    } 
}

function NewAssistReg() {
    var username = user;//from the default page the user is declared there
    var fname = $("#namesInput").val();
    var snric = $("#nric").val();
    var address = $("#addresssInput").val();
    var postal = $("#postalsInput").val();
    var mobtel = $("#mobilesInput").val();
    var alttel = $("#altInput").val();
    var hometel = $("#homesInput").val();
    var sex = $("#sexinput").val();
    var nationality = $("#nationalsInput").val();
    var dob = $("#daterange").val();
    var race = "Chinese"; 
    var age = 23;
    var temp = $("#temp").val();
    var Email = $("#emailsInput").val();
    var purpose = $("#pInput").val();
    var pName = $("#patientName").val();
    var pNric = $("#patientNric").val();
    var otherPurpose = $("#purposeInput").val();
    var bedno = $("#bedno").val();
    var visTime = $("#visitbookingtime").val();
    var visDate = $("#visitbookingdate").val();
    var appTime = visDate + " " + visTime;
    var fever = $("#fever").val();
    var symptoms = $("#pimple").val();
    var influenza = $("#flu").val();
    var countriesTravelled = $("#sg").val();
    var remarks = $("#remarksinput").val();
    var visitLoc = $("#visLoc").val();

    var headersToProcess = {
        staffUser:username,fullName: fname, nric: snric, ADDRESS: address, POSTAL: postal, MobTel: mobtel, email: Email,
        AltTel: alttel, HomeTel: hometel, SEX: sex, Natl: nationality, DOB: dob, RACE: race, AGE: age, PURPOSE: purpose,pName: pName, pNric: pNric,
        otherPurpose: otherPurpose, bedno: bedno, appTime: appTime, fever: fever, symptoms: symptoms, influenza: influenza,
        countriesTravelled: countriesTravelled, remarks: remarks, visitLocation: visitLoc, requestType: "confirmation", temperature: temp
    };
    $.ajax({
        url: './CheckInOut/checkIn.ashx',
        method: 'post',
        data: headersToProcess,


        success: function (returner) {
            var resultOfGeneration = JSON.parse(returner);
            if (resultOfGeneration.Result === "Success") {
                var today = new Date();
                alert("Visitor successfully checked-in at " + today.getDay() + "/" + today.getMonth() + "/" + today.getYear() + " " + today.getHours() + ":" + today.getMinutes());
            } else {
                alert("Error: " + resultOfGeneration.Msg);
            }
        },
        error: function (err) {
            alert(err.Msg);
        },
    });
}