/// <reference path="registrationPageScripts.js" />
$(document).ready(function () {
    if (allowVisit) {
        hideTags(false);//when page loads
        //only allow text evnts
        $("#bedno").keydown(function (e) {
            // Allow: backspace, delete, tab, escape, enter and .
            if ($.inArray(e.keyCode, [46, 8, 9, 27, 13, 110, 190]) !== -1 ||
                // Allow: Ctrl/cmd+A
                (e.keyCode == 65 && (e.ctrlKey === true || e.metaKey === true)) ||
                // Allow: Ctrl/cmd+C
                (e.keyCode == 67 && (e.ctrlKey === true || e.metaKey === true)) ||
                // Allow: Ctrl/cmd+X
                (e.keyCode == 88 && (e.ctrlKey === true || e.metaKey === true)) ||
                // Allow: home, end, left, right
                (e.keyCode >= 35 && e.keyCode <= 39)) {
                // let it happen, don't do anything
                return;
            }
            // Ensure that it is a number and stop the keypress
            if ((e.shiftKey || (e.keyCode < 48 || e.keyCode > 57)) && (e.keyCode < 96 || e.keyCode > 105)) {
                e.preventDefault();
            }
        });

        // Boot the floating tab
        $('.kc_fab_wrapper').kc_fab(links);
    }
});

$('#navigatePage a:first').tab('show');
$('#regPageNavigation a:first').tab('show');
w3IncludeHTML();

// Variable to check if all fields are valid
var validMob = true;
var validAlt = true;
var validHom = true;
var validNRIC = false;
var validTemp = false;
var validPos = true;
var validDate = true;
var validEmail = true;
var regCompleted = false;
var allowVisit = true;
var init = false;
var lowTemp = "34";
var highTemp = "40";
var warnTemp = "37.6";
var visLim = 3;
var regUrl = '../Staff/CheckInOut/CheckInGateway.ashx';
var configUrl = '../Staff/MasterConfig/MasterConfigGateway.ashx';
var links = [
{
    "bgcolor":"#03A9F4",
    "icon":"+"
},
{
    "url": "hideTagsFalse",
    "bgcolor":"#DB4A39",
    "color":"#fffff",
    "icon": "<i class='fa fa-undo'></i>",
    "target":"Clear Fields"
},
{
    "url": "checkNric",
    "bgcolor": "#a58512",
    "color": "#fffff",
    "icon": "<i class='fa fa-search'></i>",
    "target": "Check NRIC"
},
{
    "url": "submitAssistReg",
    "bgcolor": "#1a8220",
    "color": "#fffff",
    "icon": "<i class='fa fa-file'></i>",
    "target": "Submit Registration"
}
];


/**
 * Check for visitor details & any online self registration information
 * @param 
 * @return 
 */
function callCheck (){
        var nricValue = nric.value;
        var visDate = $('#visitbookingdate').val();
        var msg;
        var headersToProcess = { nric: nricValue, requestType: "getdetails" }; 
        $.ajax({
            url: regUrl,
            method: 'post',
            data: headersToProcess,


            success: function (returner) {
                var resultOfGeneration = JSON.parse(returner);
                if (resultOfGeneration.Result === "Success") {
                    var visitorString = resultOfGeneration.Visitor;
                    if (resultOfGeneration.Visitor === "new") {
                        clearFields(false);
                        $('#visitbookingdate').val(visDate);
                    } else {
                        var visitObj = resultOfGeneration.Visit;
                        var questionnaireAns = resultOfGeneration.Questionnaire;
                        var questionnaireArr = [];
                        if (resultOfGeneration.Visitor != null) {
                            if (resultOfGeneration.Questionnaire != null) {
                                try {
                                    questionnaireArr = resultOfGeneration.Questionnaire.Main;
                                } catch (err) {

                                }
                            }
                        }
                        if (resultOfGeneration.Visitor !== "new") {
                            $("#nric").prop('value', resultOfGeneration.Visitor.nric);
                            $("#namesInput").prop('value', resultOfGeneration.Visitor.name);
                            $("#sexinput").prop('value', resultOfGeneration.Visitor.gender);
                            $("#nationalsInput").val(resultOfGeneration.Visitor.nationality);
                            $("#daterange").val(resultOfGeneration.Visitor.dob.toString()); 
                            $("#addresssInput").prop('value', resultOfGeneration.Visitor.address);
                            $("#postalsInput").prop('value', resultOfGeneration.Visitor.postal);
                            $("#mobilesInput").prop('value', resultOfGeneration.Visitor.contactNum);
                        } if (visitObj !== undefined) {
                            $("#visitbookingdate").val(visitObj.visReqTime.substring(0, 10));
                            $("#visitbookingtime").val(visitObj.visReqTime.substring(11, 16));
                            var visPurpose = visitObj.purpose;
                            $('#pInput').val(visPurpose);
                            if (visPurpose == "Visit Patient") {
                                $("#patientpurposevisit").css("display", "block");
                                $("#otherpurposevisit").css("display", "none");
                            } else if (visPurpose == "Other Purpose") {
                                $("#patientpurposevisit").css("display", "none");
                                $("#otherpurposevisit").css("display", "block");
                                $("#visLoc").prop('value', visitObj.visitLocation);
                                $("#purposeInput").prop('value', visitObj.otherPurpose);
                            }
                            if (visitObj.bedno.length > 0) {
                                $(visitObj.bedno.split('|')).each(function () {
                                    loadBedPatientName(this);
                                });
                            }
                            $("#qaid").prop('value', visitObj.qAid);
                            $("#remarks").prop('value', visitObj.remarks);
                        } else {
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
                                } else {
                                    timeStr = (date.getHours() + 1) + ":00";
                                }
                            } else {
                                if (date.getHours() < 10) {
                                    timeStr = "0" + date.getHours() + ":30";
                                } else {
                                    timeStr = (date.getHours()) + ":30";
                                }
                            }
                            $("#visitbookingtime").val(timeStr);
                        } if (questionnaireArr.length >= 1) {
                            for (i = 0; i < questionnaireArr.length; i++) {
                                var jsonAnswerObject = questionnaireArr[i];
                                var qid = jsonAnswerObject.qid;
                                var answer = jsonAnswerObject.answer
                                if (answer.includes(",")) { // Checkbox
                                    var arr = answer.split(",");
                                    for (i = 0; i < arr.length; i++) {
                                        var answerOpt = arr[i];
                                        $("#questionaireForm input[name='" + qid + "'][value='" + answerOpt + "']").prop("checked", true);
                                    }
                                } else {
                                    $('#' + qid).val(answer);
                                    $("#questionaireForm input[id='" + qid + "']").prop("value", answer);
                                    $("#questionaireForm input[id='" + qid + "'][value='" + answer + "']").prop("checked", true) // Radio
                                } 
                            }
                        }
                        else if (resultOfGeneration.Visitor === "new" & visitObj === undefined & questionnaireArr.length == 0) {
                            clearFields(false);
                            // Except Visit Date
                            $('#visitbookingdate').val(visDate);
                            $("#nric").prop('value', nricValue);
                        }
                        $("#nric").prop('disabled', true);
                        $("#temp").prop('disabled', true);
                    }
                    $('#main').animate({
                        scrollTop: $("#userData").offset().top
                    }, 200);
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

/**
 * Load patient name & bed number
 * @param 
 * @return 
 */
function loadBedPatientName(bedno) {
    var patientBedRequest = { requestType: "pName", bedNo: "" + bedno };
    var patientName = "";
    $.ajax({
        url: regUrl,
        method: 'post',
        data: patientBedRequest,


        success: function (returner) {
            var patientNm = JSON.parse(returner);
            if (patientNm.name != null) {
                patientName = patientNm.name;
                addBedToVisit(patientName, bedno);
            }

        },
        error: function (error) {

        }
    });
}

/**
 * Loads all facilities in the hospital
 * @param 
 * @return 
 */
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

/**
 * Check nationality input field
 * @param 
 * @return 
 */
function checkNationals() {
    var blank = checkBlankField($("#nationalsInput").val());
    if (blank) {
        $("#natWarning").css("display", "block");
    } else {
        $("#natWarning").css("display", "none");
    }
    return !blank;
}

/**
 * Check gender input field
 * @param 
 * @return 
 */
function checkGender() {
    var blank = checkBlankField($("#sexinput").val());
    if (blank) {
        $("#sexWarning").css("display", "block");
    } else {
        $("#sexWarning").css("display", "none");
    }
    return !blank;
}

/**
 * Check visit time input field
 * @param 
 * @return 
 */
function checkTime() {
    var blank = checkBlankField($("#visitbookingtime").val());
    if (blank) {
        $("#timelabel").css("display", "block");
    } else {
        $("#timelabel").css("display", "none");
    }
    return !blank;
}

/**
 * Add bed to list
 * @param 
 * @return 
 */
function addBedToVisit(patientName, patientBedNo) {

    if ($("#bedsAdded #"+patientBedNo).prop("id") != null) {
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

/**
 * Ensure patient info is valid
 * @param 
 * @return 
 */
function validatePatient() {
    var pName = $("#patientName").val();
    var bedno = $("#bedno").val();
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
                var string = resultOfGeneration.Msg;
                var arr = string.split(",");
                if (arr.length > 2) {
                    $("#patientNric").prop('value', arr[0]);
                    $("#patientName").prop('value', arr[1]);
                    $("#bedno").prop('value', arr[2]);
                    $("#patientStatusGreen").css("display", "block");
                    $("#patientStatusRed").css("display", "none");
                    addBedToVisit(arr[1], arr[2]);
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

/**
 * Check visitor's temperature
 * @param 
 * @return 
 */
$("#temp").on("input", function () {
    var temper = $("#temp").val();
    if (checkBlankField(temper)) {
        $('#tempLimitWarning').css("display", "none");
        $('#tempWarning').css("display", "none");
        $("#invalidTempWarning").css("display", "none");
        $('#lowtempWarning').css("display", "none");
        validTemp = false;
    } else {
        try {
            var temperature = parseFloat(temper);
            if (temperature > parseFloat(highTemp)) {
                $('#tempLimitWarning').html("Visitor's Temperature is above the allowable " + highTemp + " degrees celcius!");
                $('#tempLimitWarning').css("display", "block");
                $('#tempWarning').css("display", "none");
                $("#invalidTempWarning").css("display", "none");
                $('#lowtempWarning').css("display", "none");
                validTemp = false;
            } else if (isNaN(temperature)) {
                $("#invalidTempWarning").css("display", "block");
                $('#tempWarning').css("display", "none");
                $('#tempWarning').css("display", "none");
                $('#lowtempWarning').css("display", "none");
                validTemp = false;
            }
            else if (temperature < parseFloat(lowTemp)) {
                $('#lowtempWarning').html("Visitor's Temperature is below the allowable " + lowTemp + " degrees celcius!");
                $('#lowtempWarning').css("display", "block");
                $('#tempLimitWarning').css("display", "none");
                $('#tempWarning').css("display", "none");
                $("#invalidTempWarning").css("display", "none");
                validTemp = false;
            }
            else if (temperature > parseFloat(warnTemp)) {
                $('#tempLimitWarning').css("display", "none");
                $("#invalidTempWarning").css("display", "none");
                $('#lowtempWarning').css("display", "none");
                $('#tempWarning').html("Warning Fever!");
                $('#tempWarning').css("display", "block");
                validTemp = true;
            }
            else {
                $('#tempLimitWarning').css("display", "none");
                $('#tempWarning').css("display", "none");
                $("#invalidTempWarning").css("display", "none");
                $('#lowtempWarning').css("display", "none");
                validTemp = true;
                if (validTemp && validNRIC) {
                    showMenu();
                }
            }
        } catch (ex) {
            $('#tempWarning').css("display", "block");
            validTemp = false;
        }
    }
});

/**
 * ASHX page call to write info to DB
 * @param 
 * @return 
 */
function NewAssistReg() {
    var username = user; 
    var fname = $("#namesInput").val();
    var snric = $("#nric").val();
    var address = $("#addresssInput").val();
    var postal = $("#postalsInput").val();
    var mobtel = $("#mobilesInput").val();
    var alttel = "";
    var hometel = "";
    var sex = $("#sexinput").val();
    var nationality = $("#nationalsInput").val();
    var dob = $("#daterange").val();
    var race = ""; 
    var age = 0;
    var temp = $("#temp").val();
    var Email = "";
    var purpose = $("#pInput").val();
    var pName = $("#patientName").val();
    var pNric = $("#patientNric").val();
    var otherPurpose = $("#purposeInput").val();
    var bedno ="";
    var bedsLength = $("#bedsAdded").children().length;
    $("#bedsAdded").children().each(function (idx, iitem) {
        bedno += $(this).prop('id');
        var parent = $(this).parent();
        if (idx + 1 < bedsLength) {
            bedno += "|";
        }
    });
    var qListID = $("#qnlistid").val();
    var visTime = $("#visitbookingtime").val();
    var visDate = $("#visitbookingdate").val();
    var appTime = visDate + " " + visTime;
    var remarks = $("#remarksinput").val();
    var visitLoc = $("#visLoc").val();
    var qAnswers = getQuestionnaireAnswers();
    var qaid = $("#qaid").val();

    var headersToProcess = {
        staffUser:username,fullName: fname, nric: snric, ADDRESS: address, POSTAL: postal, MobTel: mobtel, email: Email,
        AltTel: alttel, HomeTel: hometel, SEX: sex, Natl: nationality, DOB: dob, RACE: race, AGE: age, PURPOSE: purpose,pName: pName, pNric: pNric,
        otherPurpose: otherPurpose, bedno: bedno, appTime: appTime, remarks: remarks, visitLocation: visitLoc, requestType: "confirmation", temperature: temp, qListID: qListID, qAnswers: qAnswers, qaid: qaid, visLim: visLim
    };
    $.ajax({
        url: regUrl,
        method: 'post',
        data: headersToProcess,
        success: function (returner) {
            try {
                var resultOfGeneration = JSON.parse(returner);
                if (resultOfGeneration.Result === "Success") {
                        regCompleted = true;
                        showSuccessModal();
                        hideTags(false); 
            } else {
                    if (resultOfGeneration.Visitor.toString().includes("per bed has been reached")) {
                        showMaxLimitModal();
                        hideTags(true);
                        regCompleted = true;
                    } 
                    else if (resultOfGeneration.Visitor !== "1") {
                        alert("Error: " + resultOfGeneration.Visitor);
                    } else if (resultOfGeneration.Questionnaire !== "1") {
                        alert("Error: " + resultOfGeneration.Visit);
                    } else if (resultOfGeneration.Visit !== "1") {
                        alert("Error: " + resultOfGeneration.Visit);
                    }
                }
            } catch (err) {
                alert("Error: " + err.message);
            }
        },
        error: function (err) {
            alert(err.Msg);
        },
    });
    $('input[id="ignoreNric"]').prop('checked', false);
    $('input[id="ambulCheck"]').prop('checked', false);
    var allowNric = false;
}
 
/**
 * ASHX page call to write info to DB for express entry
 * @param 
 * @return 
 */
function NewExpressReg() {
    var username = user;
    var snric = $("#nric").val();
    var qListID = $("#qnlistid").val();
    var remarks = $("#remarksExpressInput").val();
    var qAnswers = getQuestionnaireAnswers();
    var qaid = $("#qaid").val();

    var headersToProcess = {
        staffUser: username, nric: snric, remarks: remarks, requestType: "express", qListID: qListID, qAnswers: qAnswers, qaid: qaid
    };
    $.ajax({
        url: regUrl,
        method: 'post',
        data: headersToProcess,
        success: function (returner) {
            try {
                var resultOfGeneration = JSON.parse(returner);
                if (resultOfGeneration.Result === "Success") {
                    regCompleted = true;
                    showSuccessModal();
                    hideTags(false);
                } else {
                    alert("Not Checked In");
                }
            } catch (err) {
                alert("Error: " + err.message);
            }
        },
        error: function (err) {
            alert(err.Msg);
        },
    });
    $('input[id="ignoreNric"]').prop('checked', false);
    $('input[id="ambulCheck"]').prop('checked', false);
    var allowNric = false;
}

/**
 * Partially or wholly clears the user fields based on a boolean value
 * @param 
 * @return 
 */
function clearFields(overwrite) {
    if (allowVisit) {
        if (overwrite) {
            $("#registration .regInput").each(function (idx, obj) {
                if ($(obj).attr("id") != "visitbookingdate") {
                    $(obj).prop("value", "");
                    $(obj).css('background', '#ffffff');
                }
            });
            regCompleted = false;
        } else {
            if (regCompleted) {
                $("#registration .regInput").each(function (idx, obj) {
                    if ($(obj).attr("id") != "visitbookingdate") {
                        $(obj).prop("value", "");
                        $(obj).css('background', '#ffffff');
                    }
                });
                regCompleted = false;
            } else {
                $("#registration .regInput").each(function (idx, obj) {
                    if ($(obj).attr("id") != "nric" && $(obj).attr("id") != "temp") {
                        $(obj).prop("value", "");
                        $(obj).css('background', '#ffffff');
                    }
                });
            }
            $('input[id="ignoreNric"]').prop('checked', false);
            var allowNric = false;
        }
        $("#bedsAdded").html("");
        $("#nric").prop('disabled', false);
        $("#temp").prop('disabled', false);
        $("#tempDiv").css("display", "block");
    }
}

/**
 * Display appropriate panels according to visit purpose
 * @param 
 * @return 
 */
function purposePanels() {
    var purpose = $("#pInput").val();
    if (purpose === "Visit Patient") {
        $("#otherpurposevisit .regInput").each(function (idx, obj) {
             $(obj).prop("value", "");
        });
        $("#patientpurposevisit").css("display", "block");
        $("#otherpurposevisit").css("display", "none");
        $("#purWarning").css("display", "none");
        $('#visLoc').prop('value', "");
        $('#purposeInput').val("");
        $('#otherpurposevisit input').removeClass('required');
        return true;
    } else if (purpose === "Other Purpose") {
        $("#patientpurposevisit .regInput").each(function (idx, obj) {
            $(obj).prop("value", "");
        });
        $("#patientpurposevisit").css("display", "none");
        $("#otherpurposevisit").css("display", "block");
        $("#purWarning").css("display", "none");
        $('#patientName').prop('value', "");
        $('#patientNric').prop('value', "");
        $('#bedno').prop('value', "");
        $("#patientStatusRed").css("display", "none");
        $("#patientStatusGreen").css("display", "none");
        $('#patientpurposevisit input').removeClass('required');
        $('#otherpurposevisit input').addClass('required');
        return true;
    } else {
        $("#patientpurposevisit").css("display", "none");
        $("#otherpurposevisit").css("display", "none");
        $("#purWarning").css("display", "block");
        $('#patientName').prop('value', "");
        $('#patientNric').prop('value', "");
        $('#bedno').prop('value', "");
        $('#visLoc').val("");
        $('#purposeInput').prop('value', "");
        $("#patientStatusRed").css("display", "none");
        $("#patientStatusGreen").css("display", "none");
    }
    return false;
}

/**
 * Check visit location input field
 * @param 
 * @return 
 */
function checkLocation() {
    var blank = checkBlankField($("#visLoc").val());
    if (blank) {
        $("#locWarning").css("display", "block");
    } else {
        $("#locWarning").css("display", "none");
    }
    return !blank;
}

/**
 * Checks the filling of the required fields
 * @param 
 * @return 
 */
function checkRequiredFields() {
    var valid = true;
    $.each($("#registration input.required"), function (index, value) {
        var element = $(value).val();
        if (!element || element == "") {
            valid = false;
            $(value).css('background', '#f3f78a');
        }
    });

    var purpose = $("#pInput").val();
    if (purpose === "Visit Patient") {
        if ($("#bedsAdded").children().length == 0) {
            $("#bedsAdded").css('background', '#f3f78a');
            valid = false;
        }
    }

    if (!validMob || !validTemp || !validPos || !validDate || !checkNationals() || !purposePanels() || !checkTime() || !checkGender()) {
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

/**
 * Validate NRIC format
 * @param 
 * @return 
 */
$("#nric").on("input", function () {
    var validNric = validateNRIC($("#nric").val());
    if (validNric !== false) {
        $("#emptyFields").css("display", "none");
        $("#nricWarnDiv").css("display", "none");
        validNRIC = true;
        if (validTemp && validNRIC) {
            showMenu();
        }
    } else {
        $("#nricWarnDiv").css("display", "block");
    }
});

/**
 * Validate mobile phone number format
 * @param 
 * @return 
 */
$("#mobilesInput").on("input", function () {
    var validPhone = validatePhone($("#mobilesInput").val());
    if (validPhone) {
        $("#mobWarning").css("display", "none");
    } else {
        $("#mobWarning").css("display", "block");
    }
    validMob = validPhone;
});

/**
 * Validate postal code number format
 * @param 
 * @return 
 */
$("#postalsInput").on("input", function () {
    var validPostal = validatePostal($("#postalsInput").val());
    if (validPostal) {
        $("#posWarning").css("display", "none");
    } else {
        $("#posWarning").css("display", "block");
    }
    validPos = validPostal;
});

/**
 * Check if visitor record exists in database
 * @param 
 * @return 
 */
function checkExistOrNew() {
    $("#emptyNricWarning").css("display", "none");
    if (validTemp) {
        callCheck();
        $("#newusercontent").css("display", "block");
        $("#staticinfocontainer").css("display", "block");
    } else {
        $("#invalidTempWarning").css("display", "block");
    }
}

/**
 * Get Questionnaire Answers by .answer class
 * @param 
 * @return 
 */
function getQuestionnaireAnswers() {
    var answers = '';
    var questions = [];
    var qIds = [];
    var allAnswers = [];
    var holder = [];
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
            var check = element.is(':checked');
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
        var answers = "";
        for (var j = 0; j < allAnswers.length; j++) {
            var row = allAnswers[j];
            var arr = row.split(':');
            var id = arr[0];
            if (id == currentQid) {
                var ans = arr[1];
                answers += ans + ",";
            }
        }
        answers = answers.substring(0, answers.length - 1);
        var obj = { qid: currentQid, question: questions[i], answer: answers };
        holder.push(obj);
    }
    var jsonObject = {Main:holder};
    var jsonString = JSON.stringify(jsonObject);
    return jsonString;
}

/**
 * Datetime Picker JQuery
 * @param 
 * @return 
 */
$(function () {
    $('#datetimepicker').datetimepicker({
        defaultDate: new Date(),
        maxDate: 'now',
        format: 'DD-MM-YYYY',
        ignoreReadonly: true
    });
    $('#visitbookingdatediv').datetimepicker(
        {
            defaultDate: new Date(),
            maxDate: 'now',
            format: 'DD-MM-YYYY'
        });
});

/**
 * Date picker formatter
 * @param 
 * @return 
 */
function getFormattedDate(date) {
    var day = date.getDate();
    var month = date.getMonth() + 1;
    var year = date.getFullYear().toString().slice(2);
    return day + '-' + month + '-' + year;
}

/**
 * Check date format
 * @param 
 * @return 
 */
$("#daterange").on("input", function () {
    var dateStr = $('#daterange').val();
    var valid = validateDate(dateStr);
    if (valid) {
        $("#dateWarning").css("display", "none");
    } else {
        $("#dateWarning").css("display", "block");     
    }
    validDate = valid;
});

/**
 * Hide all warnings on page load
 * @param 
 * @return 
 */
function hideTags(clear) {
    if (clear) {
        clearFields(true);
    }
    $("#invalidTempWarning").css("display", "none");
    $("#emptyFields").css("display", "none");
    $("#emptyNricWarning").css("display", "none");
    $("#emailWarning").css("display", "none");
    $("#remarksExpressDiv").css("display", "none");
    $('#lowtempWarning').css("display", "none");
    $('#tempWarning').css("display", "none");
    $('#tempLimitWarning').css("display", "none");
    $("#patientpurposevisit").css("display", "none");
    $("#otherpurposevisit").css("display", "none");
    $("#dateWarning").css("display", "none");
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
        hideSettingsModal();
        getVisLim();
        loadFacilities();
        populateTime();
        populateRegNationalities();
        loadActiveForm();
        init = true;
    }
}

/**
 * Button settings for check nric button
 * @param 
 * @return 
 */
function enterToCheckNric(e) {
    if (e.which == 13 || e.keyCode == 13) {
        checkNricWarningDeclaration(); false; }
}

// Check nature of NRIC
/**
 * Populates the dropdown list from tracing by location
 * @param 
 * @return 
 */
function checkNricWarningDeclaration() {
    if (checkBlankField($("#nric").val())) {
        $("#emptyNricWarning").css("display", "block");
        allowNric = $('input[id="ignoreNric"]').is(':checked');
    } else if ($('input[id="ambulCheck"]').is(':checked')) {
        if ($("#remarksExpressInput").val() !== "") {
            NewExpressReg();
        } else {
            alert("Please a reason for express entry!");
        }
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

/**
 * Check nature of Express Entry Checkbox
 * @param 
 * @return 
 */
function checkExpressDeclaration() {
    if (checkBlankField($("#nric").val())) {
        $("#emptyNricWarning").css("display", "block");
        document.getElementById("ambulCheck").checked = false;
    } else {
        var isChecked = $('input[id="ambulCheck"]').is(':checked');
        if (isChecked) {
            $("#tempLbl").prop("disabled", true);
            $("#temp").prop("disabled", true);
            $('#temp input').removeClass('required');
            $("#tempDiv").css("display", "none");
            $("#remarksExpressDiv").css("display", "block");
            $('#remarksExpressDiv textarea').addClass('required');
            $("#emptyNricWarning").css("display", "none");
        } else {
            $("#tempLbl").prop("disabled", false);
            $("#temp").prop("disabled", false);
            $('#temp input').addClass('required');
            $("#tempDiv").css("display", "block");
            $('#remarksExpressDiv textarea').removeClass('required');
            $("#remarksExpressDiv").css("display", "none");
            $("#emptyNricWarning").css("display", "none");
        }
    }
}

/**
 * Change checkbox value upon click
 * @param 
 * @return 
 */
$('#ignoreNric').on('change', function () {
     this.check;
});

/**
 * Change checkbox value upon click
 * @param 
 * @return 
 */
$('#ambulCheck').on('change', function () {
    this.check;
    checkExpressDeclaration();
});

/**
 * Loads & displays the active questionnaire from the DB for Assisted Reg
 * @param 
 * @return 
 */
function loadActiveForm() {
    $("#questionaireForm").html("");
    var k = $("#questionaireForm");
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

/**
 * Populates Nationality Field
 * @param 
 * @return 
 */
function populateRegNationalities() {
    var nationalities = getNationalityArray();
    for (var i = 0; i < nationalities.length; i++) {
        var optin = document.createElement("option");
        $(optin).attr("style", "background:white");
        $(optin).attr("name", nationalities[i]);
        $(optin).html(nationalities[i]);
        $('#nationalsInput').append(optin);
    }
}

/**
 * Populates Visit Time Field
 * @param 
 * @return 
 */
function populateTime() {
    var lowTime = "";
    var adjustedTime = false;
    var highTime = "";
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
        } else {
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
        url: configUrl,
        method: 'post',
        data: headersToProcess,


        success: function (returner) {
            var resultOfGeneration = JSON.parse(returner);
            var mes = resultOfGeneration.Msg;
            var arr = mes.toString().split(",");
            lowTime = arr[3].toString();
            highTime = arr[4].toString();
            lowTemp = arr[0].toString();
            highTemp = arr[1].toString();
            warnTemp = arr[2].toString();
            var upperLimitHit = Date.parse("01/01/2011 " + highTime) >= Date.parse("01/01/2011 " + timeStr);
            var lowLimitHit = Date.parse("01/01/2011 " + lowTime) <= Date.parse("01/01/2011 " + timeStr);
            if (upperLimitHit && lowLimitHit) {
                if (!adjustedTime) {
                    if (Date.parse("01/01/2011 " + lowTime) <= Date.parse("01/01/2011 " + timeStr)) {
                        lowTime = timeStr;
                    }
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
                    }
                }
            }
        },
        error: function (err) {
            alert("Error: " + err.Msg);
        },
    });
}

/**
 * Show Success Modal
 * @param 
 * @return 
 */
function showSuccessModal() {
    $('#successModal').unbind("shown.bs.modal");
    $('#successModal').on('shown.bs.modal', function () {
        getPassState();
    })
    $('#successModal').modal({ backdrop: 'static', keyboard: false });
}

/**
 * Hide Success Modal
 * @param 
 * @return 
 */
function hideSuccessModal() {
    $('#successModal').modal('hide');
    $(" #imgPass").remove();//remove the currently generated pass
    clearFields(true);//clear all fields
}

/**
 * Show Max Limit Modal
 * @param 
 * @return 
 */
function showMaxLimitModal() {
    $('#maxLimitModal').modal({ backdrop: 'static', keyboard: false });
    $('#maxLimitModal').modal('show');
}

/**
 * Hide Max Limit Modal
 * @param 
 * @return 
 */
function hideMaxLimitModal() {
    $('#maxLimitModal').modal('hide');
}

/**
 * Email Format Validation
 * @param 
 * @return 
 */
$("#emailsInput").on("input", function () {
    var email = $("#emailsInput").val();
    var valid = validateEmail(email);
    if (valid) {
        $("#emailWarning").css("display", "none");
    } else {
        $("#emailWarning").css("display", "block");
    }
    validEmail = valid;
});

/**
 * Get visitor limit
 * @param 
 * @return 
 */
function getVisLim() {
    var headersToProcess = {
        requestType: "getConfig"
    };
    $.ajax({
        url: configUrl,
        method: 'post',
        data: headersToProcess,


        success: function (returner) {
            var resultOfGeneration = JSON.parse(returner);
            var mes = resultOfGeneration.Msg;
            var arr = mes.toString().split(",");
            fillAccessProfileList();
            if (arr.length > 1) {
                visLim = arr[5];
            }
        },
        error: function (err) {
            alert("Error: " + err.Msg);
        },
    });
}