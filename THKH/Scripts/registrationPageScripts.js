/// <reference path="registrationPageScripts.js" />
$(document).ready(function () {
    
    // ajax call here
});

function callCheck (){
    //Do ajax call

    var nricValue = nric.value;
    var msg;
    var headersToProcess = { nric: nricValue }; //Store objects in this manner 
    $.ajax({
        url: './CheckInOut/checkIn.ashx',
        method: 'post',
        data: headersToProcess,
        
        
        success: function (returner) {
            var resultOfGeneration = JSON.parse(returner);
            if (resultOfGeneration.Result == "Success") {
                DataExists(resultOfGeneration.Msg.split(','));
            } else {
                DataNoExists();
            }
        },
        error: function (err) {
        },
    });
    dataFound = true;
}

function callCheckSelf() {
    var nricValue = existnric.value;
    var msg;
    var headersToProcess = { nric: nricValue}; //Store objects in this manner 
    //var pathToCheckIn = Page.ResolveClientUrl("/Webpage/Staff/CheckInOut/checkIn.ashx")
    $.ajax({
        url: '../Staff/CheckInOut/checkIn.ashx',
        method: 'post',
        data: headersToProcess,


        success: function (returner) {
            var resultOfGeneration = JSON.parse(returner);
            if (resultOfGeneration.Result == "Success") {
                var result = resultOfGeneration.Msg;
                if (resultOfGeneration.Msg == "found") {
                    DataExistsSelf();
                } else {
                    DataNoExistsSelf();
                }
            } else {
                DataNoExistsSelf();
            }
        },
        error: function (err) {
            alert(err.msg);
        },
    });
    dataFound = true;
}

function DataExistsSelf() {
    $('#nricexistlabel').css("display", "block");
    $('#nricnotexistlabel').css("display", "none");
}

function DataNoExistsSelf() {
    $('#nricnotexistlabel').css("display", "block");
    $('#nricexistlabel').css("display", "none");
}

function DataExists(arr) {
    var htmStr = "";
    var count = 0;
    arr.forEach(function (element) {
        htmStr += "<br/>" + element
    });
    $('#Details').html(htmStr);
    $('#Details').css("display", "block");
    $('#tempField').css("display", "block");
}

function DataNoExists() {
    $('#Details').html("Visitor Not Found. Please register the visitor.");
}

function CheckIn() {
    var temper = temp.value;
    if (parseFloat(temper) > 37.6) {
        $('#Details').html("Temperature is Above 37.6 Degrees Celcius. No Entry!");
        $('#Details').css("display", "block");
        $('#Details').css("color", "red");
    } else {
        var check = "true";
        var headersToProcess = { nric: nric.value, temperature: temper };
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
            },
        });
        dataFound = true;
    }
}

function NewSelfReg() {
    var fname = $("#namesInput").val();
    var lname = $("#lnamesInput").val();
    var snric = $("#nricsInput").val();
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
    var selfReg = $('#isNew').val();

    var headersToProcess = {
        firstName: fname, lastName: lname, nric: snric, ADDRESS: address, POSTAL: postal, MobTel: mobtel, email: Email,
        AltTel: alttel, HomeTel: hometel, SEX: sex, Natl: nationality, DOB: dob, RACE: race, AGE: age, PURPOSE: purpose, pName: pName, pNric: pNric,
        otherPurpose: otherPurpose, bedno: bedno, appTime: appTime, fever: fever, symptoms: symptoms, influenza: influenza,
        countriesTravelled: countriesTravelled, remarks: remarks, visitLocation: visitLoc, ASSISTED: selfReg
    };
    $.ajax({
        url: './CheckInOut/checkIn.ashx',
        method: 'post',
        data: headersToProcess,


        success: function (returner) {
            var resultOfGeneration = JSON.parse(returner);
            alert(resultOfGeneration.Msg);
        },
        error: function (err) {
        },
    });
}

function NewAssistReg() {
    var fname = $("#namesInput").val();
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
        countriesTravelled: countriesTravelled, remarks: remarks, visitLocation: visitLoc, ASSISTED: 'no'
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
        },
    });
}