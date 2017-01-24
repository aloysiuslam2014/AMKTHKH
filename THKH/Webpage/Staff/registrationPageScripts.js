/// <reference path="registrationPageScripts.js" />
$(document).ready(function () {
    
    // ajax call here
});

$('#navigatePage a:first').tab('show');
$('#regPageNavigation a:first').tab('show');
w3IncludeHTML();

// Variable to check if all fields are valid
var validMob = true;
var validAlt = true;
var validHom = true;
var validTemp = true;
var validPos = true;
var validEmail = true;
var regCompleted = false;
var init = false;

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
                var visitorString = resultOfGeneration.Visitor;
                if (resultOfGeneration.Visitor === "new") {
                    clearFields();
                } else {
                    var visitString = resultOfGeneration.Visit;
                    var questionnaireAns = resultOfGeneration.Questionnaire;
                    //var qaid = resultOfGeneration.QAID;
                    var visitorArr = [];
                    var visitArr = [];
                    var questionnaireArr = [];
                    if (resultOfGeneration.Visit != null & resultOfGeneration.Visit != "0") {
                        visitArr = visitString.split(",");
                    }
                    if (resultOfGeneration.Visitor != null) {
                        visitorArr = visitorString.split(",");
                        if (resultOfGeneration.Questionnaire != null) {
                            try {
                                questionnaireArr = JSON.parse(resultOfGeneration.Questionnaire).Main;
                            } catch (err) {

                            }
                        }
                    }
                    if (visitorArr.length > 1) {
                        // Populate fields if data exists
                        $("#nric").prop('value', visitorArr[0]);
                        $("#namesInput").prop('value', visitorArr[1]);
                        $("#sexinput").prop('value', visitorArr[2].trim());
                        $("#nationalsInput").val(visitorArr[3]);
                        $("#daterange").val(visitorArr[4].toString()); // Error
                        $("#addresssInput").prop('value', visitorArr[6]);
                        $("#postalsInput").prop('value', visitorArr[7]);
                        $("#mobilesInput").prop('value', visitorArr[5]);
                        //$("#altInput").prop('value', visitorArr[8]);
                        //$("#homesInput").prop('value', visitorArr[7]);
                        //$("#emailsInput").prop('value', visitorArr[9]);
                    } if (visitArr.length > 1) {
                        $("#visitbookingdate").val(visitArr[0].toString().substring(0, 10));
                        $("#visitbookingtime").val(visitArr[0].toString().substring(11, 16));
                        $("#patientNric").prop('value', visitArr[1]);
                        $("#patientName").prop('value', visitArr[3]);
                        var visPurpose = visitArr[4];
                        $('#pInput').val(visitArr[4]); // Purpose of visit "Visit Patient" or "Other Purpose"
                        if (visPurpose == "Visit Patient") {
                            $("#patientpurposevisit").css("display", "block");
                            $("#otherpurposevisit").css("display", "none");
                        } else if (visPurpose == "Other Purpose") {
                            $("#patientpurposevisit").css("display", "none");
                            $("#otherpurposevisit").css("display", "block");
                        }
                        $("#purposeInput").prop('value', visitArr[5]);
                        $("#visLoc").prop('value', visitArr[6]);
                        $("#bedno").prop('value', visitArr[7]);
                        $("#qaid").prop('value', visitArr[8]);
                        $("#remarks").prop('value', visitArr[9]);
                    } if (questionnaireArr.length > 1) {
                        for (i = 0; i < questionnaireArr.length; i++) {
                            var jsonAnswerObject = questionnaireArr[i];
                            var qid = jsonAnswerObject.qid;
                            var answer = jsonAnswerObject.answer
                            //$("#" + qid).prop('value', answer);
                            $('#' + qid).val(answer);
                            $("#questionaireForm input[name='" + qid + "'][value='" + answer + "']").prop("checked", true);
                            $("#questionaireForm input[id='" + qid + "']").prop("value", answer);
                        }
                        //$("#qaid").prop('value', qaid);
                    }
                    else if (visitorArr.length == 0 & visitArr.length == 0 & questionnaireArr.length == 0) {
                        clearFields();
                        $("#nric").prop('value', nricValue);
                    }
                }
                $('#main').animate({
                    scrollTop: $("#userData").offset().top
                }, 1000);
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

// Loads all facilities in the hospital
function loadFacilities() {
    var headersToProcess = {
        requestType: "facilities"
    };
    $.ajax({
        url: '../Staff/CheckInOut/checkIn.ashx',
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

// Check nationality input field
function checkNationals() {
    if ($("#nationalsInput").val() == '') {
        $("#natWarning").css("display", "block");
        return false;
    } else {
        $("#natWarning").css("display", "none");
    }
    return true;
}

// Check gender input field
function checkGender() {
    if ($("#sexinput").val() == '') {
        $("#sexWarning").css("display", "block");
        return false;
    } else {
        $("#sexWarning").css("display", "none");
    }
    return true;
}

// Check visit time input field
function checkTime() {
    if ($("#visitbookingtime").val() == '') {
        $("#timelabel").css("display", "block");
        return false;
    } else {
        $("#timelabel").css("display", "none");
    }
    return true;
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
                    $("#patientNric").prop('value', arr[0]);
                    $("#patientName").prop('value', arr[1]);
                    $("#bedno").prop('value', arr[2]);
                    $("#patientStatusGreen").css("display", "block");
                    $("#patientStatusRed").css("display", "none");
                }else {
                    alert("Patient Not Found!");
                    $("#patientStatusGreen").css("display", "none");
                    $("#patientStatusRed").css("display", "block");
                }
            } else {
                $("#patientStatusRed").css("display", "block");
                $("#patientStatusGreen").css("display", "none");
            }
        },
        error: function (err) {
            alert("Error: " + err.msg + ". Please contact the adminsitrator.");
        },
    });
}

// Check visitor's temperature
$("#temp").on("input", function () {
    var temper = $("#temp").val();
    if (temper == "") {
        $('#tempWarning').css("display", "none");
        $("#invalidTempWarning").css("display", "none");
        validTemp = false;
    } else {
        try {
            var temperature = parseFloat(temper);
            if (temperature > 37.6) {
                $('#tempWarning').css("display", "block");
                $("#invalidTempWarning").css("display", "none");
                validTemp = false;
            } else if (isNaN(temperature) || temperature < 35.0) {
                $("#invalidTempWarning").css("display", "block");
                $('#tempWarning').css("display", "none");
                validTemp = false;
            }
            else {
                $('#tempWarning').css("display", "none");
                $("#invalidTempWarning").css("display", "none");
                validTemp = true;
            }
        } catch (ex) {
            $('#tempWarning').css("display", "block");
            validTemp = false;
        }
    }
});

// ASHX page call to write info to DB
function NewAssistReg() {
    var username = user; 
    var fname = $("#namesInput").val();
    var snric = $("#nric").val();
    var address = $("#addresssInput").val();
    var postal = $("#postalsInput").val();
    var mobtel = $("#mobilesInput").val();
    //var alttel = $("#altInput").val();
    //var hometel = $("#homesInput").val();
    var alttel = "";
    var hometel = "";
    var sex = $("#sexinput").val();
    var nationality = $("#nationalsInput").val();
    var dob = $("#daterange").val();
    var race = ""; 
    var age = 0;
    var temp = $("#temp").val();
    //var Email = $("#emailsInput").val();
    var Email = "";
    var purpose = $("#pInput").val();
    var pName = $("#patientName").val();
    var pNric = $("#patientNric").val();
    var otherPurpose = $("#purposeInput").val();
    var bedno = $("#bedno").val();
    var qListID = $("#qnlistid").val();
    var visTime = $("#visitbookingtime").val();
    var visDate = $("#visitbookingdate").val();
    var appTime = visDate + " " + visTime;
    //var fever = $("#fever").val();
    //var symptoms = $("#pimple").val();
    //var influenza = $("#flu").val();
    //var countriesTravelled = $("#sg").val();
    var remarks = $("#remarksinput").val();
    var visitLoc = $("#visLoc").val();
    var qAnswers = getQuestionnaireAnswers();
    var qaid = $("#qaid").val();

    var headersToProcess = {
        staffUser:username,fullName: fname, nric: snric, ADDRESS: address, POSTAL: postal, MobTel: mobtel, email: Email,
        AltTel: alttel, HomeTel: hometel, SEX: sex, Natl: nationality, DOB: dob, RACE: race, AGE: age, PURPOSE: purpose,pName: pName, pNric: pNric,
        otherPurpose: otherPurpose, bedno: bedno, appTime: appTime, remarks: remarks, visitLocation: visitLoc, requestType: "confirmation", temperature: temp, qListID: qListID, qAnswers: qAnswers, qaid: qaid
    };
    $.ajax({
        url: './CheckInOut/checkIn.ashx',
        method: 'post',
        data: headersToProcess,


        success: function (returner) {
            var resultOfGeneration = JSON.parse(returner);
            if (resultOfGeneration.Result === "Success") {
                if (resultOfGeneration.Visitor === "Visitor Limit Reached!") {
                    // Show Error Modal!
                    showMaxLimitModal();
                    clearFields();
                    //$('input:checkbox[name=declare]').attr('checked', false);
                    hideTags();
                    regCompleted = true;
                } else {
                    var today = new Date();
                    regCompleted = true;
                    showSuccessModal();
                    var purpose = $("#pInput").val("");
                    //after showin then we load the pass go to the method show success modal to see
                    //clearfields moved to passManage.js to grab data before it is cleaned please DO NOT CLEAR FIELDS B4 PASS IS GENERATED!!!!!
                   
                    //$('input:checkbox[name=declare]').attr('checked', false);
                    hideTags();
                }
              
            } else {
                alert("Error: " + resultOfGeneration.Msg);
            }
        },
        error: function (err) {
            alert(err.Msg);
        },
    });
    $('input[id="ignoreNric"]').prop('checked', false);
}

function clearFields() {
    if (regCompleted) {
        $("#registration .regInput").each(function (idx, obj) {
            $(obj).prop("value", "");
        });
        regCompleted = false;
    } else {
        $("#registration .regInput").each(function (idx, obj) {
            if ($(obj).attr("id") != "nric" && $(obj).attr("id") != "temp") {
                $(obj).prop("value", "");
            }
        });
    }
}

// Display appropriate panels according to visit purpose
function purposePanels() {
    var purpose = $("#pInput").val();
    if (purpose === "Visit Patient") {
        $("#patientpurposevisit").css("display", "block");
        $("#otherpurposevisit").css("display", "none");
        $("#purWarning").css("display", "none");
        return true;
    } else if (purpose === "Other Purpose") {
        $("#patientpurposevisit").css("display", "none");
        $("#otherpurposevisit").css("display", "block");
        $("#purWarning").css("display", "none");
        return true;
    } else {
        $("#patientpurposevisit").css("display", "none");
        $("#otherpurposevisit").css("display", "none");
        $("#purWarning").css("display", "block");
    }
    return false;
}

// Check visit location input field
function checkLocation() {
    if ($("#visLoc").val() == '') {
        $("#locWarning").css("display", "block");
        return false;
    } else {
        $("#locWarning").css("display", "none");
    }
    return true;
}

// For field validations
function checkRequiredFields() {
    var valid = true;
    $.each($("#registration input.required"), function (index, value) {
        var element = $(value).val();
        if (!element || element == "") {
            valid = false;
            $(value).css('background', '#f3f78a');
        }
    });
    if (!validMob || !validHom || !validAlt || !validTemp || !validPos || !checkNationals() || !purposePanels() || !checkTime() || !checkGender() || !validEmail) {
        valid = false;
    }
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

// Validate mobile phone number format
$("#mobilesInput").on("input", function () {
    var validNric = validatePhone($("#mobilesInput").val());
    if (validNric !== false) {
        $("#mobWarning").css("display", "none");
        validMob = true;
    } else {
        $("#mobWarning").css("display", "block");
        validMob = false;
    }
});

// Validate postal code number format
$("#postalsInput").on("input", function () {
    var validNric = validatePhone($("#postalsInput").val());
    if (validNric !== false) {
        $("#posWarning").css("display", "none");
        validPos = true;
    } else {
        $("#posWarning").css("display", "block");
        validPos = false;
    }
});

// Validate home phone number format
$("#homesInput").on("input", function () {
    var validNric = validatePhone($("#homesInput").val());
    if (validNric !== false) {
        $("#homeWarning").css("display", "none");
        validHom = true;
    } else {
        $("#homeWarning").css("display", "block");
        validHom = false;
    }
});

// Validate alt phone number format
$("#altInput").on("input", function () {
    var validNric = validatePhone($("#altInput").val());
    if (validNric !== false) {
        $("#altWarning").css("display", "none");
        validAlt = true;
    } else {
        $("#altWarning").css("display", "block");
        validAlt = false;
    }
});

// Check if visitor record exists in database
function checkExistOrNew() {
        $("#emptyNricWarning").css("display", "none");
        callCheck();
        $("#newusercontent").css("display", "block");
        $("#staticinfocontainer").css("display", "block");
}

// Get Questionnaire Answers by .answer class
function getQuestionnaireAnswers() {
    var answers = '';
    var jsonObject = "{\"Main\":[";
    var questions = [];
    var qIds = [];
    var allAnswers = [];
    // Get label values
    $("#questionaireForm .question").each(function (index, value) {
        var question = $(this).text();
        var id = $(this).attr('for');
        qIds.push(id);
        questions.push(question);
    });

    // get question answers
    $("#questionaireForm .answer").each(function (index, value) {
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
        var answerObject = "{\"qid\":\"" + currentQid + "\",\"question\":\"" + questions[i] + "\",\"answer\":\"";
        for (var j = 0; j < allAnswers.length; j++) {
            var row = allAnswers[j];
            var arr = row.split(':');
            var id = arr[0];
            if (id == currentQid) {
                var ans = arr[1];
                answerObject += ans + ",";
            }
        }
        answerObject = answerObject.substring(0, answerObject.length - 1);
        answerObject += "\"},";
        jsonObject += answerObject;
    }
    jsonObject = jsonObject.substring(0, jsonObject.length - 1);
    jsonObject += "]}";
    var jsonString = JSON.stringify(jsonObject);
    return jsonString;
}

// Check if user has checked the "I declare the info to be accurate" checkbox
//function declarationValidation() {
//    if ($("#declaration").prop('checked') == true) {
//        $("#declabel").css("display", "none");
//        $("#submitNewEntry").css("display", "block");
//    } else {
//        $("#declabel").css("display", "block");
//        $("#submitNewEntry").css("display", "none");
//    }
//}

// Datetime Picker JQuery
$(function () {
    $('#datetimepicker').datetimepicker({
        // dateFormat: 'dd-mm-yy',
        defaultDate: new Date(),
        maxDate: 'now',
        format: 'DD-MM-YYYY'
    });
    $('#visitbookingdatediv').datetimepicker(
        {
            // dateFormat: 'dd-mm-yy',
            defaultDate: new Date(),
            maxDate: 'now',
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
    $("#emptyNricWarning").css("display", "none");
    $("#emailWarning").css("display", "none");
    $('#tempWarning').css("display", "none");
    $("#patientpurposevisit").css("display", "none");
    $("#otherpurposevisit").css("display", "none");
    //$("#submitNewEntry").css("display", "none");
    $("#newusercontent").css("display", "none");
    $("#staticinfocontainer").css("display", "none");
    $("#nricWarnDiv").css("display", "none");
    $("#mobWarning").css("display", "none");
    $("#homeWarning").css("display", "none");
    $("#altWarning").css("display", "none");
    $("#patientStatusGreen").css("display", "none");
    $("#patientStatusRed").css("display", "none");
    $("#posWarning").css("display", "none");
    $("#natWarning").css("display", "none");
    $("#purWarning").css("display", "none");
    $("#sexWarning").css("display", "none");
    $("#locWarning").css("display", "none");
    $("#timelabel").css("display", "none");
    if (!init) {
        loadFacilities();
        populateTime();
        populateRegNationalities();
        loadActiveForm();
        init = true;
    }
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
    //var check = this.is(":checked");
    //if (check) {
    //    $(this).prop('checked', false);
    //} else {
    //    $(this).prop('checked', true);
    //}
    // Old Code
     this.check;
});

// Loads & displays the active questionnaire from the DB for Assisted Reg
function loadActiveForm() {
    $("#questionaireForm").html("");
    var k = $("#questionaireForm");
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
function populateRegNationalities() {
    var nationalities = [
        'Singaporean',
        'Afghan',
        'Albanian',
        'Algerian',
        'American',
        'Andorran',
        'Angolan',
        'Antiguans',
        'Argentinean',
        'Armenian',
        'Australian',
        'Austrian',
        'Azerbaijani',
        'Bahamian',
        'Bahraini',
        'Bangladeshi',
        'Barbadian',
        'Barbudans',
        'Batswana',
        'Belarusian',
        'Belgian',
        'Belizean',
        'Beninese',
        'Bhutanese',
        'Bolivian',
        'Bosnian',
        'Brazilian',
        'British',
        'Bruneian',
        'Bulgarian',
        'Burkinabe',
        'Burmese',
        'Burundian',
        'Cambodian',
        'Cameroonian',
        'Canadian',
        'Cape Verdean',
        'Central African',
        'Chadian',
        'Chilean',
        'Chinese',
        'Colombian',
        'Comoran',
        'Congolese',
        'Costa Rican',
        'Croatian',
        'Cuban',
        'Cypriot',
        'Czech',
        'Danish',
        'Djibouti',
        'Dominican',
        'Dutch',
        'East Timorese',
        'Ecuadorean',
        'Egyptian',
        'Emirian',
        'Equatorial Guinean',
        'Eritrean',
        'Estonian',
        'Ethiopian',
        'Fijian',
        'Filipino',
        'Finnish',
        'French',
        'Gabonese',
        'Gambian',
        'Georgian',
        'German',
        'Ghanaian',
        'Greek',
        'Grenadian',
        'Guatemalan',
        'Guinea-Bissauan',
        'Guinean',
        'Guyanese',
        'Haitian',
        'Herzegovinian',
        'Honduran',
        'Hungarian',
        'I-Kiribati',
        'Icelander',
        'Indian',
        'Indonesian',
        'Iranian',
        'Iraqi',
        'Irish',
        'Israeli',
        'Italian',
        'Ivorian',
        'Jamaican',
        'Japanese',
        'Jordanian',
        'Kazakhstani',
        'Kenyan',
        'Kittian and Nevisian',
        'Kuwaiti',
        'Kyrgyz',
        'Laotian',
        'Latvian',
        'Lebanese',
        'Liberian',
        'Libyan',
        'Liechtensteiner',
        'Lithuanian',
        'Luxembourger',
        'Macedonian',
        'Malagasy',
        'Malawian',
        'Malaysian',
        'Maldivan',
        'Malian',
        'Maltese',
        'Marshallese',
        'Mauritanian',
        'Mauritian',
        'Mexican',
        'Micronesian',
        'Moldovan',
        'Monacan',
        'Mongolian',
        'Moroccan',
        'Mosotho',
        'Motswana',
        'Mozambican',
        'Namibian',
        'Nauruan',
        'Nepalese',
        'New Zealander',
        'Nicaraguan',
        'Nigerian',
        'Nigerien',
        'North Korean',
        'Northern Irish',
        'Norwegian',
        'Omani',
        'Pakistani',
        'Palauan',
        'Panamanian',
        'Papua New Guinean',
        'Paraguayan',
        'Peruvian',
        'Polish',
        'Portuguese',
        'Qatari',
        'Romanian',
        'Russian',
        'Rwandan',
        'Saint Lucian',
        'Salvadoran',
        'Samoan',
        'San Marinese',
        'Sao Tomean',
        'Saudi',
        'Scottish',
        'Senegalese',
        'Serbian',
        'Seychellois',
        'Sierra Leonean',
        'Slovakian',
        'Slovenian',
        'Solomon Islander',
        'Somali',
        'South African',
        'South Korean',
        'Spanish',
        'Sri Lankan',
        'Sudanese',
        'Surinamer',
        'Swazi',
        'Swedish',
        'Swiss',
        'Syrian',
        'Taiwanese',
        'Tajik',
        'Tanzanian',
        'Thai',
        'Togolese',
        'Tongan',
        'Trinidadian/Tobagonian',
        'Tunisian',
        'Turkish',
        'Tuvaluan',
        'Ugandan',
        'Ukrainian',
        'Uruguayan',
        'Uzbekistani',
        'Venezuelan',
        'Vietnamese',
        'Welsh',
        'Yemenite',
        'Zambian',
'Zimbabwean'];
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
    var time = [
        '07:00',
        '07:30',
        '08:00',
        '08:30',
        '09:30',
        '10:00',
        '10:30',
        '11:00',
        '11:30',
        '12:00',
        '12:30',
        '13:00',
        '13:30',
        '14:00',
        '14:30',
        '15:00',
        '15:30',
        '16:00',
        '16:30',
        '17:00',
        '17:30',
        '18:00',
        '18:30',
        '19:00',
        '19:30',
        '20:00',
        '20:30',
        '21:00',
        '21:30'];
    for (var i = 0; i < time.length; i++) {
        var optin = document.createElement("option");
        $(optin).attr("style", "background:white");
        $(optin).attr("name", time[i]);
        $(optin).attr("value", time[i]);
        $(optin).html(time[i]);
        $('#visitbookingtime').append(optin);
    }
}

// Show Success Modal
function showSuccessModal() {
    $('#successModal').on('shown.bs.modal', function () {
        getPassState();
    })
    $('#successModal').modal({ backdrop: 'static', keyboard: false });
}

// Hide Success Modal
function hideSuccessModal() {
    $('#successModal').modal('hide');
    $(" #passClone").remove();//remove the currently generated pass
}

// Show Max Limit Modal
function showMaxLimitModal() {
    $('#maxLimitModal').modal({ backdrop: 'static', keyboard: false });
    $('#maxLimitModal').modal('show');
}

// Hide Max Limit Modal
function hideMaxLimitModal() {
    $('#maxLimitModal').modal('hide');
}

// Email Format Validation
$("#emailsInput").on("input", function () {
    var email = $("#emailsInput").val();
    if (/^\w+([\.-]?\w+)*@\w+([\.-]?\w+)*(\.\w{2,3})+$/.test(email)) {
        $("#emailWarning").css("display", "none");
        validEmail = true;
    } else {
        $("#emailWarning").css("display", "block");
        validEmail = false;
    }
});

