/// <reference path="registrationPageScripts.js" />
$(document).ready(function () {
    
    // ajax call here
});

//var user = '<%=Session["username"].ToString()%>';
$('#navigatePage a:first').tab('show');
$('#regPageNavigation a:first').tab('show');
w3IncludeHTML();

// Check for visitor details & any online self registration information
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
                if (arr.length > 5) {
                    var dateString = arr[4].replace(/-/g, "/").toString() + " 0:01 AM";
                    // Populate fields if data exists
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
                    // Clear fields
                    clearFields();
                }
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

// ensure patient info is valid
function validatePatient() {
    // Logic to validate patient with THK Patient DB. If patient is valid, set a global variable to enable the submit button of the form
    var pName = $("#patientName").val();
    var bedno = $("#bedno").val();
    var headersToProcess = {
        pName: pName, bedno: bedno, requestType: "patient"
    };
    $.ajax({
        url: './CheckInOut/checkIn.ashx',
        method: 'post',
        data: headersToProcess,


        success: function (returner) {
            var resultOfGeneration = JSON.parse(returner);
            if (resultOfGeneration.Result === "Success") {
                var string = resultOfGeneration.Msg;
                var arr = string.split(",");
                if (arr.length > 2) {
                    $("#patientNric").attr('value', arr[0]);
                    $("#patientName").attr('value', arr[1]);
                    $("#bedno").attr('value', arr[2]);
                }else {
                    alert("Patient Not Found!");
                }
            } else {
                alert("Error: " + resultOfGeneration.Msg);
            }
        },
        error: function (err) {
        },
    });
}

// Check visitor's temperature
function checkTemp() { 
    var temper = temp.value;
    try{
        var temperature = parseFloat(temper);
        if (temperature > 37.6) {
            $('#tempWarning').css("display", "block");
            $("#invalidTempWarning").css("display", "none");
        } if (temperature < 35.0) {
            $("#invalidTempWarning").css("display", "block");
            $('#tempWarning').css("display", "none");
        }
        else {
            $('#tempWarning').css("display", "none");
            $("#invalidTempWarning").css("display", "none");
        }
    }catch(ex){
        $('#tempWarning').css("display", "block");
    }
    
}

// ASHX page call to write info to DB
function NewAssistReg() {
    var username = user; 
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
    var qListID = $("#qnlistid").val();
    var appTime = Date.now();
    var fever = $("#fever").val();
    var symptoms = $("#pimple").val();
    var influenza = $("#flu").val();
    var countriesTravelled = $("#sg").val();
    var remarks = $("#remarksinput").val();
    var visitLoc = $("#visLoc").val();
    var qAnswers = getQuestionnaireAnswers();

    var headersToProcess = {
        staffUser:username,fullName: fname, nric: snric, ADDRESS: address, POSTAL: postal, MobTel: mobtel, email: Email,
        AltTel: alttel, HomeTel: hometel, SEX: sex, Natl: nationality, DOB: dob, RACE: race, AGE: age, PURPOSE: purpose,pName: pName, pNric: pNric,
        otherPurpose: otherPurpose, bedno: bedno, appTime: appTime, fever: fever, symptoms: symptoms, influenza: influenza,
        countriesTravelled: countriesTravelled, remarks: remarks, visitLocation: visitLoc, requestType: "confirmation", temperature: temp, qListID: qListID, qAnswers: qAnswers
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
                clearFields();
            } else {
                alert("Error: " + resultOfGeneration.Msg);
            }
        },
        error: function (err) {
            alert(err.Msg);
        },
    });
}

function clearFields() {
    $("#nric").attr('value', "");
    $("#namesInput").attr('value', "");
    $("#sexinput").attr('value', "");
    $("#nationalsInput").attr('value', "");
    $("#daterange").attr('value', "");
    $("#addresssInput").attr('value', "");
    $("#postalsInput").attr('value', "");
    $("#mobilesInput").attr('value', "");
    $("#altInput").attr('value', "");
    $("#homesInput").attr('value', "");
    $("#emailsInput").attr('value', "");
    $("#visitbookingtime").attr('value', "");
    $("#visitbookingdate").attr('value', "");
    $("#patientNric").attr('value', "");
    $("#patientName").attr('value', "");
    $('#pInput').val(""); // Purpose of visit "Visit Patient" or "Other Purpose"
    $("#purposeInput").attr('value', "");
    $("#visLoc").attr('value', "");
}

// Display appropriate panels according to visit purpose
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

// Validate NRIC format
$("#nric").on("input", function () {
    var validNric = validateNRIC($("#nric").val());
    if (validNric !== false) {
        $("#emptyFields").css("display", "none");
        $("#nricWarnDiv").css("display", "none");
    } else {
        $("#nricWarnDiv").css("display", "block");
    }
});

// Check if visitor record exists in database
function checkExistOrNew() {
    //// Call to ASHX page
        $("#emptyNricWarning").css("display", "none");
        callCheck();
        $("#newusercontent").css("display", "block");
        $("#staticinfocontainer").css("display", "block");
}

// Get Questionnaire Answers by .answer class gives back a JSON String
function getQuestionnaireAnswers() {
    var answers = '{';
    $.each($("#registration input.answer"), function (index, value) { // Still Buggy
        var id = $(value).attr('id');
        if (id == null) {
            id = $(value).attr('name');
        }
        answers += id + ':' + $(value).val() + ',';
    });
    answers = answers.substring(0, answers.length - 1) + '}';
    var jsonString = JSON.stringify(answers);
    return jsonString;
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

// hide all warnings on page load
function hideTags() {
    $("#invalidTempWarning").css("display", "none");
    $("#emptyFields").css("display", "none");
    //$("#nricWarning").css("display", "none");
    $("#emptyNricWarning").css("display", "none");
    $('#tempWarning').css("display", "none");
    $("#patientpurposevisit").css("display", "none");
    $("#otherpurposevisit").css("display", "none");
    $("#submitNewEntry").css("display", "none");
    $("#newusercontent").css("display", "none");
    $("#staticinfocontainer").css("display", "none");
    $("#nricWarnDiv").css("display", "none");
    loadActiveForm();
}

function checkNricWarningDeclaration() {
    if ($("#nric").val() == "") {
        $("#emptyNricWarning").css("display", "block");
    } else {
        $("#emptyNricWarning").css("display", "none");
        var allowNric = false;
        allowNric = $('input[id="ignoreNric"]').is(':checked');
        var panelShown = $('#nricWarnDiv').is(":visible");
        if ((!allowNric & !panelShown) || (allowNric & panelShown)) {
            checkExistOrNew();
        }else {
            alert("Please check the 'Allow Anyway' Checkbox");
        }
    }
}

// Change checkbox value upon click
$('#ignoreNric').on('change', function () {
    var val = this.checked;
});

// Loads & displays the active questionnaire from the DB for Assisted Reg
function loadActiveForm() {
    $("#questionaireForm").html("");
    var headersToProcess = {
        requestType: "form"
    };
    $.ajax({
        url: './CheckInOut/checkIn.ashx',
        method: 'post',
        data: headersToProcess,


        success: function (returner) {
            var resultOfGeneration = JSON.parse(returner);
            // Display Form CSS
            var arr = resultOfGeneration.Msg;
            var htmlString = "";
            var qListID = 0;
            for (i = 0; i < arr.length; i++) {
                var object = arr[i];
                qListID = object.QuestionList;
                var question = object.Question;
                var type = object.QuestionType;
                var values = object.QuestionAnswers;
                var questionNum = object.QuestionNumber;
                if (type === "ddList") {
                    htmlString += "<label for='" + questionNum + "'>" + question + "</label><label for='" + questionNum + "' id='" + i + "' style='color: red'>*</label>"
                        + "<div class='form-group'>"
                            + "<select class='form-control required answer' id='" + questionNum + "'>";
                    var valArr = values.split(",");
                    for (j = 0; j < valArr.length; j++) {
                        htmlString += "<option value='" + valArr[j] + "'>" + valArr[j] + "</option>";
                    }
                    htmlString += "</select></div>";
                }
                if (type === "radio") {
                    htmlString += "<label for='" + questionNum + "'>" + question + "</label><label for='" + questionNum + "' id='" + i + "' style='color: red'>*</label>"
                        + "<div class='form-group'>";
                    var valArr = values.split(",");
                    for (j = 0; j < valArr.length; j++) {
                        htmlString += "<div class='radio'><label><input class='answer' type='radio' name='" + questionNum + "' value='" + valArr[j] + "'";
                        if(j == 0){
                            htmlString += " checked";
                        }
                        htmlString += "/> " + valArr[j] + "</label></div>";
                    }
                    htmlString += "</div>";
                }
                if (type === "checkbox") {
                    htmlString += "<label for='" + questionNum + "'>" + question + "</label><label for='" + questionNum + "' id='" + i + "' style='color: red'>*</label>"
                        + "<div class='form-group'>";
                    var valArr = values.split(",");
                    for (j = 0; j < valArr.length; j++) {
                        htmlString += "<div class='checkbox'><label><input class='answer' type='checkbox' name='" + questionNum + "' value='" + valArr[j] + "'> " + valArr[j] + "</label></div>";
                    }
                    htmlString += "</div>";
                } if (type === "text") {
                    htmlString += "<label for='" + questionNum + "'>" + question + "</label>"
                                    + "<label for='" + questionNum + "' id='" + i + "' style='color: red'>*</label>"
                                    + "<div class='form-group'>"
                                    + "<input type='text' runat='server' class='form-control required answer' id='" + questionNum + "' />"
                                    + "</div>";
                }
            }
            htmlString += "<input type='hidden' runat='server' class='form-control' value='" + qListID + "' id='qnlistid' />";
            var formElement = document.createElement("DIV");
            $(formElement).attr("class", "list-group-item");
            $(formElement).attr("style", "text-align: left");
            $(formElement).attr("data-color", "info");
            $(formElement).attr("id", 17);
            $(formElement).html(htmlString);
            $("#questionaireForm").append(formElement);
        },
        error: function (err) {
        },
    });
}