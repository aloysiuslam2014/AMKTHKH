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


// Check for visitor details & any online self registration information
function callCheck (){
    //Do ajax call
        var nricValue = nric.value;
        var visDate = $('#visitbookingdate').val();
        var msg;
        var headersToProcess = { nric: nricValue, requestType: "getdetails" }; //Store objects in this manner 
        $.ajax({
            url: regUrl,
            method: 'post',
            data: headersToProcess,


            success: function (returner) {
                var resultOfGeneration = JSON.parse(returner);
                if (resultOfGeneration.Result === "Success") {
                    // ASHX returns all the visitor information
                    // Populate fields if visitor exists by spliting string into array of values & populating
                    var visitorString = resultOfGeneration.Visitor;
                    if (resultOfGeneration.Visitor === "new") {
                        clearFields(false);
                        $('#visitbookingdate').val(visDate);
                    } else {
                        var visitObj = resultOfGeneration.Visit;
                        var questionnaireAns = resultOfGeneration.Questionnaire;
                        //var visitorArr = [];
                        //var visitArr = [];
                        var questionnaireArr = [];
                        //if (resultOfGeneration.Visit != null & resultOfGeneration.Visit != "0") {
                        //    visitArr = visitString.split(",");
                        //}
                        if (resultOfGeneration.Visitor != null) {
                            //visitorArr = visitorString.split(",");
                            if (resultOfGeneration.Questionnaire != null) {
                                try {
                                    questionnaireArr = resultOfGeneration.Questionnaire.Main;
                                } catch (err) {

                                }
                            }
                        }
                        if (resultOfGeneration.Visitor !== "new") {
                            // Populate fields if data exists
                            $("#nric").prop('value', resultOfGeneration.Visitor.nric);
                            $("#namesInput").prop('value', resultOfGeneration.Visitor.name);
                            $("#sexinput").prop('value', resultOfGeneration.Visitor.gender);
                            $("#nationalsInput").val(resultOfGeneration.Visitor.nationality);
                            $("#daterange").val(resultOfGeneration.Visitor.dob.toString()); // Error
                            $("#addresssInput").prop('value', resultOfGeneration.Visitor.address);
                            $("#postalsInput").prop('value', resultOfGeneration.Visitor.postal);
                            $("#mobilesInput").prop('value', resultOfGeneration.Visitor.contactNum);
                        } if (visitObj !== undefined) {
                            $("#visitbookingdate").val(visitObj.visReqTime.substring(0, 10));
                            $("#visitbookingtime").val(visitObj.visReqTime.substring(11, 16));
                            var visPurpose = visitObj.purpose;
                            $('#pInput').val(visPurpose); // Purpose of visit "Visit Patient" or "Other Purpose"
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
                                $(visitObj.bedno.split('|')).each(function () {//split bed no if possible then create the beds
                                    loadBedPatientName(this);
                                });
                            }
                            $("#qaid").prop('value', visitObj.qAid);
                            $("#remarks").prop('value', visitObj.remarks);
                        } if (questionnaireArr.length >= 1) {
                            for (i = 0; i < questionnaireArr.length; i++) {
                                var jsonAnswerObject = questionnaireArr[i];
                                var qid = jsonAnswerObject.qid;
                                var answer = jsonAnswerObject.answer
                                $('#' + qid).val(answer);
                                $("#questionaireForm input[name='" + qid + "'][value='" + answer + "']").prop("checked", true); // Checkbox
                                $("#questionaireForm input[id='" + qid + "']").prop("value", answer);
                                $("#questionaireForm input[id='" + qid + "'][value='" + answer + "']").prop("checked", true) // Radio
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

// Load patient name & bed number
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

// Check nationality input field
function checkNationals() {
    var blank = checkBlankField($("#nationalsInput").val());
    if (blank) {
        $("#natWarning").css("display", "block");
    } else {
        $("#natWarning").css("display", "none");
    }
    return !blank;
}

// Check gender input field
function checkGender() {
    var blank = checkBlankField($("#sexinput").val());
    if (blank) {
        $("#sexWarning").css("display", "block");
    } else {
        $("#sexWarning").css("display", "none");
    }
    return !blank;
}

// Check visit time input field
function checkTime() {
    var blank = checkBlankField($("#visitbookingtime").val());
    if (blank) {
        $("#timelabel").css("display", "block");
    } else {
        $("#timelabel").css("display", "none");
    }
    return !blank;
}


// Add bed to list
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

// ensure patient info is valid
function validatePatient() {
    // Logic to validate patient with THK Patient DB. If patient is valid, set a global variable to enable the submit button of the form
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
                    // Need logic here to check if visitor limit for that particular bed has been reached
                    //add to current beds visiting field
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

// Check visitor's temperature
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
                $('#tempWarning').html("Visitor's Temperature is above the allowable " + warnTemp + " degrees celcius!");
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

// ASHX page call to write info to DB
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
                        //after showin then we load the pass go to the method show success modal to see
                        
                        hideTags(false); //clearfields moved to close button on success modal
                    

            } else {
                    if (resultOfGeneration.Visitor.toString().includes("per bed has been reached")) {
                        // Show Error Modal!
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
                alert(err.message + ". User has most likely checked-in previously today");
            }
        },
        error: function (err) {
            alert(err.Msg);
        },
    });
    $('input[id="ignoreNric"]').prop('checked', false);
    var allowNric = false;
}

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
    }
}

// Display appropriate panels according to visit purpose
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
       // $('#patientpurposevisit input').addClass('required');
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

// Check visit location input field
function checkLocation() {
    //if ($("#visLoc").val() == '') {
    //    $("#locWarning").css("display", "block");
    //    return false;
    //} else {
    //    $("#locWarning").css("display", "none");
    //}
    //return true;
    var blank = checkBlankField($("#visLoc").val());
    if (blank) {
        $("#locWarning").css("display", "block");
    } else {
        $("#locWarning").css("display", "none");
    }
    return !blank;
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

    if ($("#bedsAdded").children().length == 0) {
        $("#bedsAdded").css('background', '#f3f78a');
        valid = false;
    }

    if (!validMob || !validHom || !validAlt || !validTemp || !validPos || !validDate || !checkNationals() || !purposePanels() || !checkTime() || !checkGender() || !validEmail) {
        valid = false;
    } else {
        valid = true;
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
        validNRIC = true;
        if (validTemp && validNRIC) {
            showMenu();
        }
    } else {
        $("#nricWarnDiv").css("display", "block");
    }
});

// Validate mobile phone number format
$("#mobilesInput").on("input", function () {
    var validNric = validatePhone($("#mobilesInput").val());
    if (!validNric) {
        $("#mobWarning").css("display", "none");
        //validMob = true;
    } else {
        $("#mobWarning").css("display", "block");
        //validMob = false;
    }
});

// Validate postal code number format
$("#postalsInput").on("input", function () {
    var validPostal = validatePostal($("#postalsInput").val());
    if (!validPostal) {
        $("#posWarning").css("display", "none");
        //validPos = true;
    } else {
        $("#posWarning").css("display", "block");
        //validPos = false;
    }
    validPos = validPostal;
});

// Validate home phone number format
$("#homesInput").on("input", function () {
    var validNum = validatePhone($("#homesInput").val());
    if (!validNum) {
        $("#homeWarning").css("display", "none");
        //validHom = true;
    } else {
        $("#homeWarning").css("display", "block");
        //validHom = false;
    }
    validHom = validNum;
});

// Validate alt phone number format
$("#altInput").on("input", function () {
    var validNum = validatePhone($("#altInput").val());
    if (!validNum) {
        $("#altWarning").css("display", "none");
        //validAlt = true;
    } else {
        $("#altWarning").css("display", "block");
        //validAlt = false;
    }
    validAlt = validNum;
});

// Check if visitor record exists in database
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

// Get Questionnaire Answers by .answer class
function getQuestionnaireAnswers() {
    var answers = '';
    //var jsonObject = "{\"Main\":[";
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
        var answers = "";
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
        answers = answers.substring(0, answers.length - 1);
        var obj = { qid: currentQid, question: questions[i], answer: answers };
        holder.push(obj);
        //answerObject += "\"},";
        //jsonObject += answerObject;
    }
    //jsonObject = jsonObject.substring(0, jsonObject.length - 1);
    //jsonObject += "]}";
    var jsonObject = {Main:holder};
    var jsonString = JSON.stringify(jsonObject);
    return jsonString;
}

// Datetime Picker JQuery
$(function () {
    $('#datetimepicker').datetimepicker({
        // dateFormat: 'dd-mm-yy',
        defaultDate: new Date(),
        maxDate: 'now',
        format: 'DD-MM-YYYY',
        ignoreReadonly: true
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
    var valid = validateDate(dateStr);
    if (valid) {
        $("#dateWarning").css("display", "none");
    } else {
        $("#dateWarning").css("display", "block");     
    }
    validDate = valid;
});

// hide all warnings on page load
function hideTags(clear) {
    if (clear) {
        clearFields(true);
    }
    $("#invalidTempWarning").css("display", "none");
    $("#emptyFields").css("display", "none");
    $("#emptyNricWarning").css("display", "none");
    $("#emailWarning").css("display", "none");
    //$('#noVisitWarning').css("display", "none");
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

//
function enterToCheckNric(e) {
    if (e.which == 13 || e.keyCode == 13) {
        checkNricWarningDeclaration(); false; }
}

//
function checkNricWarningDeclaration() {
    if (checkBlankField($("#nric").val())) {
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

// Populates Visit Time Field
function populateTime() {
    var lowTime = "";
    var adjustedTime = false;
    var highTime = "";
    //var count = 0;
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
                        $('#visitbookingtime').append(optin);
                        //count++;
                    }
                }
            }
            //if (count == 0) {
            //    allowVisit = false;
            //    $('#noVisitWarning').css("display", "block");
            //    $("#nric").prop('disabled', true);
            //    $("#temp").prop('disabled', true);
            //} else {
            //    allowVisit = true;
            //    $('#noVisitWarning').css("display", "none");
            //    $("#nric").prop('disabled', false);
            //    $("#temp").prop('disabled', false);
            //}
        },
        error: function (err) {
            alert("Error: " + err.Msg);
        },
    });
}

// Show Success Modal
function showSuccessModal() {
    $('#successModal').unbind("shown.bs.modal");
    $('#successModal').on('shown.bs.modal', function () {
        getPassState();
    })
    $('#successModal').modal({ backdrop: 'static', keyboard: false });
}

// Hide Success Modal
function hideSuccessModal() {
    $('#successModal').modal('hide');
    $(" #imgPass").remove();//remove the currently generated pass
    clearFields(true);//clear all fields
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
    var valid = validateEmail(email);
    if (valid) {
        $("#emailWarning").css("display", "none");
    } else {
        $("#emailWarning").css("display", "block");
    }
    validEmail = valid;
});

// Get visitor limit
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