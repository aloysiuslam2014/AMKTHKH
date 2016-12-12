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
            if (resultOfGeneration.Result == "Success") {
                // ASHX returns all the visitor information
                // Populate fields if visitor exists

            }
        },
        error: function (err) {
            alert(err.Msg);
        },
    });
    dataFound = true;
}

function CheckIn() {
    var temper = temp.value;
    if (parseFloat(temper) > 37.6) { //Check if temperature exists & meets criteria
        $('#Details').html("Temperature is Above 37.6 Degrees Celcius. No Entry!");
        $('#Details').css("display", "block");
        $('#Details').css("color", "red");
    } else {
        var check = "true";
        var headersToProcess = { nric: nric.value, temperature: temper, requestType: "checkIn" };
        $.ajax({
            url: './CheckInOut/checkIn.ashx',
            method: 'post',
            data: headersToProcess,


            success: function (returner) {
                var resultOfGeneration = JSON.parse(returner);
                $('#Details').html(resultOfGeneration.Msg);
                $('#Details').css("display", "block");
            },
            error: function (err) {
                alert(err.Msg);
            },
        });
        dataFound = true;
    }
}

function NewAssistReg() {
    var fname = $("#namesInput").val();// Fullname
    var lname = $("#lnamesInput").val();
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
    var Email = $("#emailsInput").val();
    var purpose = $("#pInput").val();
    var pName = $("#patientName").val();
    var pNric = $("#patientNric").val();
    var otherPurpose = $("#purposeInput").val();
    var bedno = $("#bedno").val();
    var appTime = $("#visitbookingtime").val();
    var fever = $("#fever").val();
    var symptoms = $("#pimple").val();
    var influenza = $("#flu").val();
    var countriesTravelled = $("#sg").val();
    var remarks = $("#remarksinput").val();
    var visitLoc = $("#visLoc").val();

    var headersToProcess = {
        firstName: fname, lastName: lname, nric: snric, ADDRESS: address, POSTAL: postal, MobTel: mobtel, email: Email,
        AltTel: alttel, HomeTel: hometel, SEX: sex, Natl: nationality, DOB: dob, RACE: race, AGE: age, PURPOSE: purpose,pName: pName, pNric: pNric,
        otherPurpose: otherPurpose, bedno: bedno, appTime: appTime, fever: fever, symptoms: symptoms, influenza: influenza,
        countriesTravelled: countriesTravelled, remarks: remarks, visitLocation: visitLoc, requestType: "confirmation"
    };
    $.ajax({
        url: './CheckInOut/checkIn.ashx',
        method: 'post',
        data: headersToProcess,


        success: function (returner) {
            var resultOfGeneration = JSON.parse(returner);
            alert(resultOfGeneration.Msg);
            $('[href="#checkIn"]').click();
            $('#nric').val(snric)
        },
        error: function (err) {
            alert(err.Msg);
        },
    });
}