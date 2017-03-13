// Variable to check if all fields are valid
var validMob = true;
var validAlt = true;
var validHom = true;
var validPos = true;
var validDate = true;
var existUser = false;
var validEmail = true;
var patientValidated = false;
var allowVisit = true;
var regUrl = '../Staff/CheckInOut/CheckInGateway.ashx';
var invalidTries = 0;

// write to form information DB
function NewSelfReg() {
    if (allowVisit) {
        var fname = $("#namesInput").val();
        var snric = $("#nricsInput").val();
        var address = $("#addresssInput").val();
        var postal = $("#postalsInput").val();
        var mobtel = $("#mobilesInput").val();
        var sex = $("#sexinput").val();
        var nationality = $("#nationalsInput").val();
        var dob = $("#daterange").val();
        var purpose = $("#pInput").val();

        var otherPurpose = $("#purposeInput").val();
        var bedno = "";
        var bedsLength = $("#bedsAdded").children().length;
        $("#bedsAdded").children().each(function (idx, iitem) {
            bedno += $(this).prop('id');
            var parent = $(this).parent();
            if (idx + 1 < bedsLength) {
                bedno += "|";
            }
        });
        var visTime = $("#visitbookingtime").val();
        var visDate = $("#visitbookingdate").val();
        var appTime = visDate + " " + visTime;
        var visitLoc = $("#visLoc").val();
        var qListID = $("#qnlistid").val();
        var qAnswers = getQuestionnaireAnswers();
        var amend = $("#amend").val();

        var headersToProcess = {
            fullName: fname, nric: snric, ADDRESS: address, POSTAL: postal, MobTel: mobtel, SEX: sex, Natl: nationality, DOB: dob, PURPOSE: purpose,
            otherPurpose: otherPurpose, bedno: bedno, appTime: appTime, visitLocation: visitLoc, requestType: "self", qListID: qListID, qAnswers: qAnswers, amend: amend
        };
        $.ajax({
            url: regUrl,
            method: 'post',
            data: headersToProcess,


            success: function (returner) {
                try{
                    var resultOfGeneration = JSON.parse(returner);
                    if (resultOfGeneration.Result === "Success") {
                        showSuccessModal();
                    } else {
                        alert("Error: Visit PK Issue");
                    }
                } catch (err) {
                    alert(err.message + ". User has most likely checked-in previously today");
                }
            },
            error: function (err) {
            },
        });
    }
}

// Check nationality input field
function checkNationals() {
    var blank = checkBlankField($("#nationalsInput").val());
    if (blank) {    
        $("#natWarning").css("display", "block");
    } else {
        $("#natWarning").css("display", "none");
    }
    return blank;
}

// Check gender input field
function checkGender() {
    var blank = checkBlankField($("#sexinput").val());
    if (blank) {
        $("#sexWarning").css("display", "block");
    } else {
        $("#sexWarning").css("display", "none");
    }
    return blank;
}

// Reload Page & Clear Cache
function reloadPage() {
    location.reload(true);
}

// Enter Button Trigger
$("#submitNric").keyup(function (event) {
    if (event.keyCode == 13) {
        $("#submitNric").click();
    }
});

//add patient to be visited
function addBedToVisit(patientName, patientBedNo) {

    if ($("#bedsAdded #" + patientBedNo).prop("id") != null) {
        alert("Patient has already been added.");
        return;
    }

    var newPatientObj = document.createElement("div");

    var closeButon = document.createElement("a");
    $(closeButon).prop("class", "close");
    $(closeButon).html("&times;");
    $(closeButon).on("click", function () {
        $(this).parent().mouseout();
        $(this).parent().remove();
        if ($(this).parent().parent().children().length == 0) {
            $("#userDetails").css("display", "none");
            $("#patientStatusGreen").css("display", "none");
            $('#staticinfocontainer').css("display", "none"); // is actually the questionaire form div
        }
    });

    $(newPatientObj).html(patientBedNo);
    $(newPatientObj).append(closeButon);



    $(newPatientObj).attr("id", patientBedNo);
    $(newPatientObj).attr("data-toggle", "tooltip");
    $(newPatientObj).attr("data-placement", "top");
    $(newPatientObj).attr("data-container", "body");
    $(newPatientObj).attr("class", "bedNoBox");
    $(newPatientObj).attr("title", patientBedNo + ": " + patientName);
    $("#patientName").val("");
    $("#bedno").val("");
    $("#bedsAdded").append(newPatientObj);
    $('[data-toggle="tooltip"]').tooltip();
}
// ensure patient info is valid
function validatePatient() {
    // Logic to validate patient with THK Patient DB. If patient is valid, set a global variable to enable the submit button of the form
    var pName = $("#patientName").val();
    var bedno = $("#bedno").val();
    if (pName !== "" && bedno !== "") {
        var headersToProcess = {
            pName: pName, bedno: bedno, requestType: "patient"
        };
        $.ajax({
            url: regUrl,
            method: 'post',
            data: headersToProcess,


            success: function (returner) {
                var resultOfGeneration = JSON.parse(returner);
                if (resultOfGeneration.Result === "Success") {
                    if (resultOfGeneration.Msg === "0") {
                        $("#patientStatusRed").css("display", "block");
                        $("#patientStatusGreen").css("display", "none");
                        $("#patientStatusNone").css("display", "none");
                        $('#newusercontent').css("display", "none");
                        $('#staticinfocontainer').css("display", "none");
                        $("#patientName").attr('readonly', false);
                        $("#bedno").attr('readonly', false);
                        plusInvalid();
                    } else {
                        $("#patientStatusGreen").css("display", "block");
                        $("#patientStatusRed").css("display", "none");
                        $("#patientStatusNone").css("display", "none");
                        patientValidated = true;
                        $("#userDetails").css("display", "block");
                        checkIfExistingVisitor();
                        addBedToVisit(pName, bedno);
                    }   
                } else {
                    $("#patientStatusRed").css("display", "block");
                    $("#patientStatusGreen").css("display", "none");
                    $("#patientStatusNone").css("display", "none");
                    $('#newusercontent').css("display", "none");
                    $('#staticinfocontainer').css("display", "none");
                    plusInvalid();
                }
            },
            error: function (err) {
                alert("Error: " + err.Msg)
            },
        });
    } else {
        $("#patientStatusNone").css("display", "block");
        $("#patientStatusRed").css("display", "none");
        $("#patientStatusGreen").css("display", "none");
        $("#userDetails").css("display", "none");
        $('#newusercontent').css("display", "none");
        $('#staticinfocontainer').css("display", "none");
        plusInvalid();
    }
}

// Increments invalid tries variable
function plusInvalid() {
    invalidTries += 1;
    if (invalidTries > 10) {
        $('#lockModal').modal({ backdrop: 'static', keyboard: false });
        $('#lockModal').modal('show');
    }
}


// Check for visitor details & any online self registration information
function checkIfExistingVisitor() {
    var snric = $("#selfRegNric").val();
    if (snric === "") {
        showNricWarning();
    } else {
        var resultOfGeneration = "";
        var headersToProcess = {
            nric: snric, requestType: "getdetails"
        };
        $.ajax({
            url: regUrl,
            method: 'post',
            data: headersToProcess,


            success: function (returner) {
                resultOfGeneration = JSON.parse(returner);
                if (resultOfGeneration.Visitor === "new") {
                    showNewContent();
                    existUser = false;
                    $("#amend").attr('value', 1);
                }
                else {
                    $('#newusercontent input').removeClass('required');
                    existUser = true;
                    showExistContent(snric);
                }
                $('#nricsInput').attr('value', snric);
            },
            error: function (err) {
                alert(err.Msg);
            },
        });
    }
}

// Show Modal on Page Load
$(window).load(function () {
    $('#myModal').modal({ backdrop: 'static', keyboard: false });
    $('#myModal').modal('show');
});

// Prevent page refresh upon submit
$("#selfregistration").submit(function (e) {
    e.preventDefault();
});

// show Visit Details DIV & Hide Modal
function showVisitDetails() {
    $('#visitDetailsDiv').css("display", "block");
    hideModal();
}

// Show empty NRIC Field warning
function showNricWarning() {
    emptyNricWarning$('#emptyNricWarning').css("display", "block");
}

// Check if required fields are filled
function checkRequiredFields() {
    var valid = true;
    var nationalitycheck = true;
    var timeCheck = false;
    var genCheck = true;
    var emCheck = true;
    if (existUser !== true) {
        nationalitycheck = checkNationals();
        genCheck = checkGender();
        emCheck = validEmail;
    }
    timeCheck = checkTime();
    $.each($("#selfregistration input.required"), function (index, value) {
        var element = $(value).val();
        if (!element || element === "") {
            valid = false;
            $(value).css('background', '#f3f78a');
        }
    });
    if (!validMob || !validHom || !validAlt || !validPos || !validDate || !nationalitycheck || !timeCheck || !genCheck || !emCheck) {
        valid = false;
    }
    if (valid) {
        $('#emptyFields').css("display", "none");
        NewSelfReg();
    }
    else {
        $('#emptyFields').css("display", "block");
    }
}

// Show Modal
function showModal() {
    $('#myModal').modal('show');
}

// Show Success Modal
function showSuccessModal() {
    $('#successModal').modal({ backdrop: 'static', keyboard: false });
    $('#successModal').modal('show');
}

// Hide Modal
function hideModal() {
    $('#myModal').modal('hide');
}

// Show Visit Details Div
function showVisitDetails() {
    $('#visitDetailsDiv').css("display", "block");
    hideModal();
}

// Show new visitor registration form
function showNewContent() {
    $('#newusercontent').css("display", "block");
    $('#staticinfocontainer').css("display", "block");
}

// Show only the Visit Purpose & Questionnaire
function showExistContent() {
    $('#visitDetailsDiv').css("display", "block");
    $('#changeddetailsdeclaration').css("display", "block");
    $('#staticinfocontainer').css("display", "block");
}

// Display Submit Button according to whether the user has checked the declaration checkbox
function declarationValidation() {
    if ($("#declaration").prop('checked') === true && patientValidated === true) {
        $("#submitNewEntry").css("display", "block");
    } else {
        $("#submitNewEntry").css("display", "none");
    }
}

// Datetime Picker JQuery
$(function () {
    $('#datetimepicker').datetimepicker({
        defaultDate: new Date(),
        maxDate: 'now',
        format: 'DD-MM-YYYY',
        ignoreReadonly: true
    });
    $('#visitbookingtimediv').datetimepicker(
        {
            defaultDate: new Date(),
            format: 'HH:mm'
        });
    $('#visitbookingdatediv').datetimepicker(
        {
            defaultDate: new Date(),
            format: 'DD-MM-YYYY',
            minDate: moment(),
            maxDate: moment().add(1, 'days'),
            ignoreReadonly: true
        });
});

// Validate NRIC format
$("#selfRegNric").on("input", function () {
    var validNric = validateNRIC($("#selfRegNric").val());
    if ($("#selfRegNric").val() == "") {
        $("#nricWarning").css("display", "none");
        $("#submitNric").prop('disabled', true);
    }
    else if (validNric !== false) {
        $("#nricWarning").css("display", "none");
        $("#submitNric").css("display", "block");
        $("#submitNric").prop('disabled', false);
    } else {
        $("#nricWarning").css("display", "block");
        $("#submitNric").css("display", "none");
        $("#submitNric").prop('disabled', true);
    }
});

// Validate mobile phone number format
$("#mobilesInput").on("input", function () {
    var validPhone = validatePhone($("#mobilesInput").val());
    if (validPhone) {
        $("#mobWarning").css("display", "none");
        //validMob = true;
    } else {
        $("#mobWarning").css("display", "block");
        //validMob = false;
    }
    validMob = validPhone;
});

// Check date format
$("#daterange").on("input", function () {
    var dateStr = $('#daterange').val();
    //var filter = /^(?:(?:31(\/|-|\.)(?:0?[13578]|1[02]))\1|(?:(?:29|30)(\/|-|\.)(?:0?[1,3-9]|1[0-2])\2))(?:(?:1[6-9]|[2-9]\d)?\d{2})$|^(?:29(\/|-|\.)0?2\3(?:(?:(?:1[6-9]|[2-9]\d)?(?:0[48]|[2468][048]|[13579][26])|(?:(?:16|[2468][048]|[3579][26])00))))$|^(?:0?[1-9]|1\d|2[0-8])(\/|-|\.)(?:(?:0?[1-9])|(?:1[0-2]))\4(?:(?:1[6-9]|[2-9]\d)?\d{2})$/;
    //if (filter.test(dateStr) !== false) {
    //    $("#dateWarning").css("display", "none");
    //    validDate = true;
    //} else {
    //    $("#dateWarning").css("display", "block");
    //    validDate = false;
    //}
    if (validateDate(dateStr)) {
        $("#dateWarning").css("display", "none");
        validDate = true;
    } else {
        $("#dateWarning").css("display", "block");
        validDate = false;
    }
});

// Validate postal code number format
$("#postalsInput").on("input", function () {
    var validNric = validatePostal($("#postalsInput").val());
    if (validNric !== false) {
        $("#posWarning").css("display", "none");
        validPos = true;
    } else {
        $("#posWarning").css("display", "block");
        validPos = false;
    }
});

// Check Other Purpose Input
function checkOtherInput() {
    var purpose = $("#purposeInput").val();
    if (checkBlankField(purpose)) {
        $('#pInput').prop('disabled', false);
    } else {
        $('#pInput').prop('disabled', true);
    }
}

// Display appropriate panels according to visit purpose
function purposePanels() {
    var purpose = $("#pInput").val();
    if (purpose === "Visit Patient") {
        $("#patientpurposevisit").css("display", "block");
        $("#otherpurposevisit").css("display", "none");
        $('#newusercontent').css("display", "none");
        $('#staticinfocontainer').css("display", "none");
        $('#newusercontent').css("display", "none");
        $('#staticinfocontainer').css("display", "none");
        $('#otherpurposevisit input').removeClass('required');
        $('#visLoc').prop('value', "");
        $('#purposeInput').val("");
    } else if (purpose === "Other Purpose") {
        $("#userDetails").css("display", "block");
        $("#patientpurposevisit").css("display", "none");
        $("#otherpurposevisit").css("display", "block");
        $('#otherpurposevisit input').addClass('required');
        $('#patientName').prop('value', "");
        $('#patientNric').prop('value', "");
        $('#bedno').prop('value', "");
        $("#patientStatusRed").css("display", "none");
        $("#patientStatusGreen").css("display", "none");
        patientValidated = true;
        checkIfExistingVisitor(); 
    } else {
        $("#userDetails").css("display", "none");
        $("#patientpurposevisit").css("display", "none");
        $("#otherpurposevisit").css("display", "none");
        $('#newusercontent').css("display", "none");
        $('#staticinfocontainer').css("display", "none");
        $('#newusercontent').css("display", "none");
        $('#staticinfocontainer').css("display", "none");
        $('#otherpurposevisit input').removeClass('required');
        $('#patientName').prop('value', "");
        $('#patientNric').prop('value', "");
        $('#bedno').prop('value', "");
        $('#visLoc').val("");
        $('#purposeInput').prop('value', "");
        $("#patientStatusRed").css("display", "none");
        $("#patientStatusGreen").css("display", "none");
    }
}

// display checkbox that allows user to declare that his/her details have changed
function amendVisitorDetails() {
    if ($("#changed").prop('checked') === true) {
        $('#newusercontent').css("display", "block");
        $('#newusercontent input').addClass('required');
        $('#emailsInput').removeClass('required');
        $('#homesInput').removeClass('required');
        $('#altInput').removeClass('required');
        $("#amend").attr('value', 1);
    } else {
        $('#newusercontent').css("display", "none");
        $('#newusercontent input').removeClass('required');
        $("#amend").attr('value', 0);
    }
}

// hide all warnings on page load
function hideTags() {
    $('#emptyNricWarning').css("display", "none");
    $('#nricWarning').css("display", "none");
    //$('#lockModal').css("display", "none");
    //$('#noVisitWarning').css("display", "none");
    $('#visitDetailsDiv').css("display", "none");
    $("#emailWarning").css("display", "none");
    $('#staticinfocontainer').css("display", "none");
    $('#changeddetailsdeclaration').css("display", "none");
    $('#newusercontent').css("display", "none");
    $("#nricexistlabel").css("display", "none");
    $("#patientpurposevisit").css("display", "none");
    $("#otherpurposevisit").css("display", "none");
    $("#dateWarning").css("display", "none");
    $("#nricnotexistlabel").css("display", "none");
    $("#submitNewEntry").css("display", "none");
    $('#emptyFields').css("display", "none");
    $("#mobWarning").css("display", "none");
    $("#homeWarning").css("display", "none");
    $("#altWarning").css("display", "none");
    $("#patientStatusGreen").css("display", "none");
    $("#patientStatusRed").css("display", "none");
    $("#patientStatusNone").css("display", "none");
    $("#userDetails").css("display", "none");
    $("#submitNric").prop('disabled', true);
    $("#patientName").attr('readonly', false);
    $("#bedno").attr('readonly', false);
    $("#submitNric").css("display", "none");
    $("#locWarning").css("display", "none");
    $("#sexWarning").css("display", "none");
    $("#timelabel").css("display", "none");
    $("#posWarning").css("display", "none");
    $("#natWarning").css("display", "none");
    populateNationalities();
    populateTime();
    loadFacilities();
    loadActiveForm();
}

// Get Questionnaire Answers by .answer class
function getQuestionnaireAnswers() {
    var answers = '';
    //var jsonObject = "{\"Main\":[";
    var questions = [];
    var qIds = [];
    var allAnswers = [];
    var holder = [];
    // Get label values
    $("#selfregistration .question").each(function (index, value) {
        var question = $(this).text();
        var id = $(this).attr('for');
        qIds.push(id);
        questions.push(question);
    });
    
    // get question answers
    $("#selfregistration .answer").each(function (index, value) {
        var element = $(this);
        var id = $(value).attr('id');
        if (id == null) {
            id = $(value).attr('name');
        }
        var type = element.prop('type');
        if (type != null & type == 'radio') {
            var check = element.attr('checked');
            if (check) {
                allAnswers.push(id + ':' + element.val());
            }
        } if (type != null & type == 'text') {
            allAnswers.push(id + ':' + element.val());
        } if (type != null & type == 'select-one') {
            allAnswers.push(id + ':' + element.val());
        } if (type != null & type == 'checkbox') {
            var check = element.is(":checked");
            if (check) {
                allAnswers.push(id + ':' + element.val());
            }
        }
    });

    // construct json answers
    for (var i = 0; i < qIds.length; i++) {
        var currentQid = qIds[i];
        //var answerObject = "{\"qid\":\"" + currentQid + "\",\"question\":\"" + questions[i] + "\",\"answer\":\"";
        for (var j = 0; j < allAnswers.length; j++) {
            var row = allAnswers[j];
            var arr = row.split(':');
            var id = arr[0];
            if (id == currentQid) {
                var ans = arr[1];
                //answerObject += ans + ",";
                answers += ans + ",";
            }
        }
        //answerObject = answerObject.substring(0, answerObject.length - 1);
        //answerObject += "\"},";
        //jsonObject += answerObject;
        answers = answers.substring(0, answers.length - 1);
        var obj = { qid: currentQid, question: questions[i], answer: answers };
        holder.push(obj);
    }
    //jsonObject = jsonObject.substring(0, jsonObject.length - 1);
    //jsonObject += "]}";
    var jsonObject = { Main: holder };
    var jsonString = JSON.stringify(jsonObject);
    return jsonString;
}

// Loads all facilities in the hospital
function loadFacilities() {
    var headersToProcess = {
        requestType: "facilities"
    };
    $.ajax({
        url: regUrl,
        method: 'post',
        data: headersToProcess,


        success: function (returner) {
            var resultOfGeneration = JSON.parse(returner);
            if (resultOfGeneration.Result === "Success") {
                var facString = resultOfGeneration.Facilities;
                if (facString !== null) {
                    var arr = facString.split(",");
                    for (s in arr) {
                        var optin = document.createElement("option");
                        $(optin).attr("style", "background:white");
                        $(optin).attr("name", arr[s]);
                        $(optin).html(arr[s]);
                        $('#visLoc').append(optin);
                    }
                }
            } else {
                alert("Error: " + resultOfGeneration.Facilities);
            }
        },
        error: function (err) {
        },
    });
}

// Loads & displays the active questionnaire from the DB for Self-Reg
function loadActiveForm() {
    var headersToProcess = {
        requestType: "form"
    };
    $.ajax({
        url: regUrl,
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
                qListID = object.qnListID;
                var question = object.qn;
                var type = object.qnType;
                var values = object.qnValues;
                var questionNum = object.qnid;
                if (type === "ddList") {
                    htmlString += "<label for='" + questionNum + "' class='question'><span style='color:red'>*</span>" + question + "</label>"
                        + "<div class='form-group'>"
                            + "<select class='form-control required answer' id='" + questionNum + "'>";
                    var valArr = values.split(",");
                    for (j = 0; j < valArr.length; j++) {
                        htmlString += "<option value='" + valArr[j] + "'>" + valArr[j] + "</option>";
                    }
                    htmlString += "</select></div>";
                }
                if (type === "radio") {
                    htmlString += "<label for='" + questionNum + "' class='question'><span style='color:red'>*</span>" + question + "</label>"
                        + "<div class='form-group'>";
                    var valArr = values.split(",");
                    for (j = 0; j < valArr.length; j++) {
                        htmlString += "<div class='radio'><label><input class='answer' type='radio' name='" + questionNum + "' value='" + valArr[j] + "'";
                        if (j == 0) {
                            htmlString += " checked";
                        }
                        htmlString += "/> " + valArr[j] + "</label></div>";
                    }
                    htmlString += "</div>";
                }
                if (type === "checkbox") {
                    htmlString += "<label for='" + questionNum + "' class='question'><span style='color:red'>*</span>" + question + "</label>"
                        + "<div class='form-group'>";
                    var valArr = values.split(",");
                    for (j = 0; j < valArr.length; j++) {
                        htmlString += "<div class='checkbox'><label><input class='answer' type='checkbox' name='" + questionNum + "' value='" + valArr[j] + "'> " + valArr[j] + "</label></div>";
                    }
                    htmlString += "</div>";
                } if (type === "text") {
                    htmlString += "<label for='" + questionNum + "' class='question'><span style='color:red'>*</span>" + question + "</label>"
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

// Populates Nationality Field
function populateNationalities() {
    var nationalities = getNationalityArray();
    for (var i = 0; i < nationalities.length; i++) {
        var optin = document.createElement("option");
        $(optin).attr("style", "background:white");
        $(optin).attr("name", nationalities[i]);
        $(optin).html(nationalities[i]);
        $('#nationalsInput').append(optin);
    }
}

// Populates Visit Time Field
function populateTime() {
    var lowTime = "";
    var highTime = "";
    var adjustedTime = false;
    var d = new Date();
    var localTime = d.getTime();
    var localOffset = d.getTimezoneOffset() * 60000;
    var utc = localTime + localOffset;
    var offset = 8;
    var singaporeTime = utc + (3600000 * offset);
    var date = new Date(singaporeTime);
    var timeStr = "";
    if (date.getMinutes() > 30) {
        if (date.getHours() == 23) {
            timeStr = "00:00";
            adjustedTime = true;
        } else if (date.getHours() < 10) {
            timeStr = "0" + (date.getHours() + 1) + ":00";
        }else {
            timeStr = (date.getHours() + 1) + ":00";
        }
    } else {
        if (date.getHours() < 10) {
            timeStr = "0" + date.getHours() + ":30";
        } else {
            timeStr = (date.getHours()) + ":30";
        }
    }
    var headersToProcess = {
        requestType: "getConfig"
    };
    $.ajax({
        url: '../Staff/MasterConfig/MasterConfigGateway.ashx',
        method: 'post',
        data: headersToProcess,


        success: function (returner) {
            var resultOfGeneration = JSON.parse(returner);
            //var count = 0;
            var mes = resultOfGeneration.Msg;
            var arr = mes.toString().split(",");
            lowTime = arr[3].toString();
            highTime = arr[4].toString();
            //var upperLimitHit = Date.parse("01/01/2011 " + highTime) >= Date.parse("01/01/2011 " + timeStr);
            //var lowLimitHit = Date.parse("01/01/2011 " + lowTime) <= Date.parse("01/01/2011 " + timeStr);
            //if (upperLimitHit && lowLimitHit) {
                if (!adjustedTime) {
                    //if (Date.parse("01/01/2011 " + lowTime) <= Date.parse("01/01/2011 " + timeStr)) {
                    //    lowTime = timeStr;
                    //}
                    var time = getTimeArray();
                    var start = time.indexOf(lowTime);
                    var end = time.indexOf(highTime);
                    for (i = start; i <= end; i++) {
                        var optin = document.createElement("option");
                        $(optin).attr("style", "background:white");
                        $(optin).attr("name", time[i]);
                        $(optin).attr("value", time[i]);
                        $(optin).html(time[i]);
                        if (time[i] == timeStr) {
                            $(optin).prop("selected", true);
                        }
                        $('#visitbookingtime').append(optin);
                        //count++;
                    }
                //}
            }
            //if (count == 0) {
            //    allowVisit = false;
            //    $('#noVisitWarning').css("display", "block");
            //    $("#selfRegNric").prop('disabled', true);
            //} else {
            //    allowVisit = true;
            //    $('#noVisitWarning').css("display", "none");
            //    $("#selfRegNric").prop('disabled', false);
            //}
        },
        error: function (err) {
            alert("Error: " + err.Msg);
        },
    });
}

// Check visit time input field
function checkTime() {
    //if ($("#visitbookingtime").val() == '') {
    //    $("#timelabel").css("display", "block");
    //    return false;
    //} else {
    //    $("#timelabel").css("display", "none");
    //}
    var blank = checkBlankField($("#visitbookingtime").val());
    if (blank) {
        $("#timelabel").css("display", "block");
    } else {
        $("#timelabel").css("display", "none");
    }
    return !blank;
}

// Check visit location input field
function checkLocation() {
    //if ($("#visLoc").val() == '') {
    //    $("#locWarning").css("display", "block");
    //    return false;
    //} else {
    //    $("#locWarning").css("display", "none");
    //}
    var blank = checkBlankField($("#visLoc").val());
    if (blank) {
        $("#locWarning").css("display", "block");
    } else {
        $("#locWarning").css("display", "none");
    }
    return blank;
}

// Email Format Validation
$("#emailsInput").on("input", function () {
    var email = $("#emailsInput").val();
    //if (email.match(/^\w+([\.-]?\w+)*@\w+([\.-]?\w+)*(\.\w{2,3})+$/)) {
    //    $("#emailWarning").css("display", "none");
    //    validEmail = true;
    //} else {
    //    $("#emailWarning").css("display", "block");
    //    validEmail = false;
    //}
    var valid = validateEmail(email);
    if (valid) {
        $("#emailWarning").css("display", "none");
    } else {
        $("#emailWarning").css("display", "block");
    }
    validEmail = valid;
});