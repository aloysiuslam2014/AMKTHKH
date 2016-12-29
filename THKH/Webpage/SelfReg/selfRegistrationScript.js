/// <reference path="selfRegistrationScript.js" />

var patientValidated = false;

// write to form information DB
function NewSelfReg() {
    var fname = $("#namesInput").val();
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
    var visTime = $("#visitbookingtime").val();
    var visDate = $("#visitbookingdate").val();
    var appTime = visDate + " " + visTime;
    var fever = $("#fever").val();
    var symptoms = $("#pimple").val();
    var influenza = $("#flu").val();
    var countriesTravelled = $("#sg").val();
    var remarks = $("#remarksinput").val();
    var visitLoc = $("#visLoc").val();
    var qListID = $("#qnlistid").val();
    var qAnswers = getQuestionnaireAnswers();

    var headersToProcess = {
        fullName: fname, nric: snric, ADDRESS: address, POSTAL: postal, MobTel: mobtel, email: Email,
        AltTel: alttel, HomeTel: hometel, SEX: sex, Natl: nationality, DOB: dob, RACE: race, AGE: age, PURPOSE: purpose, pName: pName, pNric: pNric,
        otherPurpose: otherPurpose, bedno: bedno, appTime: appTime, fever: fever, symptoms: symptoms, influenza: influenza,
        countriesTravelled: countriesTravelled, remarks: remarks, visitLocation: visitLoc, requestType: "self", qListID: qListID, qAnswers: qAnswers
    };
    $.ajax({
        url: '../Staff/CheckInOut/checkIn.ashx',
        method: 'post',
        data: headersToProcess,


        success: function (returner) {
            var resultOfGeneration = JSON.parse(returner);
            if (resultOfGeneration.Result === "Success") {
                var today = new Date();
                alert("Your online registration has been recorded at " + today.getDay() + "/" + today.getMonth() + "/" + today.getYear() + " " + today.getHours() + ":" + today.getMinutes());
                clearFields();
                window.location.reload();
            } else {
                alert("Error: " + resultOfGeneration.Msg);
            }
        },
        error: function (err) {
        },
    });
}

// Reload Page & Clear Cache
function reloadPage() {
    location.reload(true);
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
            url: '../Staff/CheckInOut/checkIn.ashx',
            method: 'post',
            data: headersToProcess,


            success: function (returner) {
                var resultOfGeneration = JSON.parse(returner);
                if (resultOfGeneration.Result === "Success") {
                    if (resultOfGeneration.Msg === "0") {
                        $("#patientStatusRed").css("display", "block");
                        $("#patientStatusGreen").css("display", "none");
                    } else {
                        $("#patientStatusGreen").css("display", "block");
                        $("#patientStatusRed").css("display", "none");
                        patientValidated = true;
                        checkIfExistingVisitor();
                    }
                    
                } else {
                    $("#patientStatusRed").css("display", "block");
                    $("#patientStatusGreen").css("display", "none");
                }
            },
            error: function (err) {
                alert("Error: " + err.Msg)
            },
        });
    } else {
        // Display warning
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
            url: '../Staff/CheckInOut/checkIn.ashx',
            method: 'post',
            data: headersToProcess,


            success: function (returner) {
                resultOfGeneration = JSON.parse(returner);
                if (resultOfGeneration.Visit === "new") {
                    showVisitDetails();
                }
                else {
                    $('#newusercontent input').removeClass('required');
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
    $.each($("#selfregistration input.required"), function (index, value) {
        if (!$(value).val()) {
            valid = false;
        }
    });
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

// Hide Modal
function hideModal() {
    $('#myModal').modal('hide');
}

// Show Visit Details Div
function showVisitDetails() {
    $('#visitDetailsDiv').css("display", "block");
    hideModal();
}

function clearFields() {
    $("#nricsInput").attr('value', "");
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
    $("#visitbookingtime").attr('value', ""); // Need to split to date & time
    $("#patientNric").attr('value', "");
    $("#patientName").attr('value', "");
    $('#pInput').val(""); // Purpose of visit "Visit Patient" or "Other Purpose"
    $("#purposeInput").attr('value', "");
    $("#visLoc").attr('value', "");
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

// Validate NRIC format
$("#selfRegNric").on("input", function () {
    var validNric = validateNRIC($("#selfRegNric").val());
    if (validNric !== false) {
        $("#nricWarning").css("display", "none");
        $("#submitNric").css("display", "block");
    } else {
        $("#nricWarning").css("display", "block");
        $("#submitNric").css("display", "none");
    }
});

// Validate mobile phone number format
$("#mobilesInput").on("input", function () {
    var validNric = validatePhone($("#mobilesInput").val());
    if (validNric !== false) {
        $("#mobWarning").css("display", "none");
    } else {
        $("#mobWarning").css("display", "block");
    }
});

// Validate home phone number format
$("#homesInput").on("input", function () {
    var validNric = validatePhone($("#homesInput").val());
    if (validNric !== false) {
        $("#homeWarning").css("display", "none");
    } else {
        $("#homeWarning").css("display", "block");
    }
});

// Validate alt phone number format
$("#altInput").on("input", function () {
    var validNric = validatePhone($("#altInput").val());
    if (validNric !== false) {
        $("#altWarning").css("display", "none");
    } else {
        $("#altWarning").css("display", "block");
    }
});

// Display appropriate panels according to visit purpose
function purposePanels() {
    var purpose = $("#pInput").val();
    if (purpose === "Visit Patient") {
        $("#patientpurposevisit").css("display", "block");
        $("#otherpurposevisit").css("display", "none");
        $('#newusercontent').css("display", "none");
        $('#staticinfocontainer').css("display", "none");
    } else if (purpose === "Other Purpose") {
        $("#patientpurposevisit").css("display", "none");
        $("#otherpurposevisit").css("display", "block");
        patientValidated = true;
        checkIfExistingVisitor(); 
    } else {
        $("#patientpurposevisit").css("display", "none");
        $("#otherpurposevisit").css("display", "none");
        $('#newusercontent').css("display", "none");
        $('#staticinfocontainer').css("display", "none");
    }
}

// display checkbox that allows user to declare that his/her details have changed
function amendVisitorDetails() {
    if ($("#changed").prop('checked') === true) {
        $('#newusercontent').css("display", "block");
    }
}

// hide all warnings on page load
function hideTags() {
    $('#emptyNricWarning').css("display", "none");
    $('#nricWarning').css("display", "none");
    $('#visitDetailsDiv').css("display", "none");
    $('#staticinfocontainer').css("display", "none");
    $('#changeddetailsdeclaration').css("display", "none");
    $('#newusercontent').css("display", "none");
    $("#nricexistlabel").css("display", "none");
    $("#patientpurposevisit").css("display", "none");
    $("#otherpurposevisit").css("display", "none");
    $("#nricnotexistlabel").css("display", "none");
    $("#submitNewEntry").css("display", "none");
    $('#emptyFields').css("display", "none");
    $("#mobWarning").css("display", "none");
    $("#homeWarning").css("display", "none");
    $("#altWarning").css("display", "none");
    $("#patientStatusGreen").css("display", "none");
    $("#patientStatusRed").css("display", "none");
    loadActiveForm();
}

// Get Questionnaire Answers by .answer class
function getQuestionnaireAnswers() {
    var answers = '{';
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
                answers += id + ':' + element.val() + ',';
            }
        } if (type != null & type == 'text') {
            answers += id + ':' + element.val() + ',';
        } if (type != null & type == 'select-one') {
            answers += id + ':' + element.val() + ',';
        } if (type != null & type == 'checkbox') {
            var check = element.is(":checked");
            if (check) {
                answers += id + ':' + element.val() + ',';
            }
        }
    });
    answers = answers.substring(0, answers.length - 1) + '}';
    var jsonString = JSON.stringify(answers);
    return jsonString;
}

// Loads & displays the active questionnaire from the DB for Self-Reg
function loadActiveForm() {
    var headersToProcess = {
        requestType: "form"
    };
    $.ajax({
        url: '../Staff/CheckInOut/checkIn.ashx',
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
                        if (j == 0) {
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