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
                $('#pInput').val(arr[17]); // Purpose of visit "Visit Patient" or "Other Purpose"
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

function validatePatient() {
    // Logic to validate patient with THK Patient DB. If patient is valid, set a global variable to enable the submit button of the form
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

var user = '<%= Session["username"].ToString()%>';
$('#navigatePage a:first').tab('show');
$('#regPageNavigation a:first').tab('show');
w3IncludeHTML();

function purposePanels() {
    var purpose = $("#pInput").val();
    if (purpose === "Visit Patient") {
        $("#patientpurposevisit").css("display", "block");
        $("#otherpurposevisit").css("display", "none");
    } else if (purpose === "Other Purpose") {
        $("#patientpurposevisit").css("display", "none");
        $("#otherpurposevisit").css("display", "block");
    } else {
        $("#patientpurposevisit").css("display", "none");
        $("#otherpurposevisit").css("display", "none");
    }
}

// For field validations
function checkRequiredFields() {
    var valid = true;
    $.each($("#main input.required"), function (index, value) {
        if (!$(value).val()) {
            valid = false;
        }
    });
    if (valid) {
        $('#emptyFields').css("display", "none");
        NewAssistReg();
    }
    else {
        $('#emptyFields').css("display", "block");
    }
}

$("#nric").on("input", function () {
    var validNric = validateNRIC($("#nric").val());
    if (validNric !== false) {
        $("#nricWarning").css("display", "none");
    } else {
        $("#nricWarning").css("display", "block");
    }
});

// Check if visitor record exists in database
function checkExistOrNew() {
    // Call to ASHX page
    if ($("#nric").val() == "") {
        $("#emptyNricWarning").css("display", "block");
    } else {
        $("#emptyNricWarning").css("display", "none");
        callCheck();
        $("#newusercontent").css("display", "block");
        $("#staticinfocontainer").css("display", "block");
    }
}

// Check if user has checked the "I declare the info to be accurate" checkbox
function declarationValidation() {
    if ($("#declaration").prop('checked') == true) {
        $("#declabel").css("display", "none");
        $("#submitNewEntry").css("display", "block");
    } else {
        $("#declabel").css("display", "block");
        $("#submitNewEntry").css("display", "none");
    }
}

// Datetime Picker JQuery
$(function () {
    $('#datetimepicker').datetimepicker({
        // dateFormat: 'dd-mm-yy',
        defaultDate: new Date(),
        format: 'DD-MM-YYYY'
    });
    $('#visitbookingtimediv').datetimepicker(
        {
            // dateFormat: 'dd-mm-yy',
            defaultDate: new Date(),
            format: 'HH:mm'
        });
    $('#visitbookingdatediv').datetimepicker(
        {
            // dateFormat: 'dd-mm-yy',
            defaultDate: new Date(),
            format: 'DD-MM-YYYY'
        });
});

// For datetimepicker
function getFormattedDate(date) {
    var day = date.getDate();
    var month = date.getMonth() + 1;
    var year = date.getFullYear().toString().slice(2);
    return day + '-' + month + '-' + year;
}

// Hiding of labels upon initial loading of page
function hideTags() {
    $("#emptyFields").css("display", "none");
    $("#nricWarning").css("display", "none");
    $("#emptyNricWarning").css("display", "none");
    $('#tempWarning').css("display", "none");
    $("#patientpurposevisit").css("display", "none");
    $("#otherpurposevisit").css("display", "none");
    $("#submitNewEntry").css("display", "none");
    $("#newusercontent").css("display", "none");
    $("#staticinfocontainer").css("display", "none");
}