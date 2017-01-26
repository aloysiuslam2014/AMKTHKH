﻿// Logic to get temp range & time range & send to ashx
var loadedTime = false;
var validSetTemp = false;
var validSetTime = false;

// update configurations
function updateConfig() {
    var username = user;
    var lowTemp = $('#temSetInputLow').val();
    var highTemp = $('#temSetInputHigh').val();
    var lowTime = $('#visTimeSetInputLower').val();
    var highTime = $('#visTimeSetInputHigh').val();
    if (lowTemp == '' & highTemp == '') {
        validSetTemp = true;
    }
    if (lowTime == '' & highTime == '') {
        validSetTime = true;
    }
    if (validSetTemp && validSetTime) {
        var headersToProcess = {
            requestType: "updateSettings", lowTemp:lowTemp, highTemp:highTemp, lowTime:lowTime, highTime:highTime, staffUser:username
        };
        $.ajax({
            url: '../Staff/MasterConfig/masterConfig.ashx',
            method: 'post',
            data: headersToProcess,


            success: function (returner) {
                var resultOfGeneration = JSON.parse(returner);
                alert("Configuration(s) Saved!");
                hideSettingsModal();
            },
            error: function (err) {

            },
        });
    }
}

// retrieve latest configuration
function getConfig() {

}

// populate time fields
function populateSettingsTime() {
    if (!loadedTime) {
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
            $('#visTimeSetInputLower').append(optin);
        }
        for (var i = 0; i < time.length; i++) {
            var optin = document.createElement("option");
            $(optin).attr("style", "background:white");
            $(optin).attr("name", time[i]);
            $(optin).attr("value", time[i]);
            $(optin).html(time[i]);
            $('#visTimeSetInputHigh').append(optin);
        }
        loadedTime = true;
    }
}

// Check lower limit temperature settings
$("#temSetInputLow").on("input", function () {
    var temper = $("#temSetInputLow").val();
    if (temper == "") {
        $('#tempSetWarning').css("display", "none");
        $("#tempRangeWarning").css("display", "none");
    } else {
        try {
            var temperature = parseFloat(temper);
            if (temperature > 34 && temperature < 40) {
                $("#tempRangeWarning").css("display", "none");
                validSetTemp = true;
                compareTemp();
            } else {
                $("#tempRangeWarning").css("display", "block");
                validSetTemp = false;
            }
        } catch (ex) {
            $('#tempSetWarning').css("display", "block");
            validSetTemp = false;
        }
    }
});

// Check upper limit temperature settings
$("#temSetInputHigh").on("input", function () {
    var temper = $("#temSetInputHigh").val();
    if (temper == "") {
        $('#tempSetWarning').css("display", "none");
        $("#tempRangeWarning").css("display", "none");
    } else {
        try {
            var temperature = parseFloat(temper);
            if (temperature > 34 && temperature < 40) {
                $("#tempRangeWarning").css("display", "none");
                validSetTemp = true;
                compareTemp();
            } else {
                $("#tempRangeWarning").css("display", "block");
                validSetTemp = false;
            }
        } catch (ex) {
            $('#tempSetWarning').css("display", "block");
            validSetTemp = false;
        }
    }
});

// compare temperature fields
function compareTemp() {
    var temp1 = $("#temSetInputLow").val();
    var temp2 = $("#temSetInputHigh").val();
    if (temp1 !== '' && temp2 !== '') {
        var low = parseFloat(temp1);
        var high = parseFloat(temp2);
        if (low > high) {
            $('#tempSetWarning').css("display", "none");
            $("#tempHighLowWarning").css("display", "block");
            validSetTemp = false;
        } else {
            $('#tempSetWarning').css("display", "none");
            $("#tempHighLowWarning").css("display", "none");
            validSetTemp = true;
        }
    } else {
        validSetTemp = false;
    }
}

// Check upper limit time settings
$("#visTimeSetInputHigh").on("input", function () {
    var time = $("#visTimeSetInputHigh").val();
    if (time == "") {
        $('#timeSetWarning').css("display", "block");
        validSetTime = false;
    } else {
        $('#timeSetWarning').css("display", "none");
        compareTime();
    }
});

// Check lower limit time settings
$("#visTimeSetInputLower").on("input", function () {
    var time = $("#visTimeSetInputLower").val();
    if (time == "") {
        $('#timeSetWarning').css("display", "block");
        validSetTime = false;
    } else {
        $('#timeSetWarning').css("display", "none");
        compareTime();
    }
});

// compare time fields
function compareTime() {
    var time1 = $("#visTimeSetInputHigh").val();
    var time2 = $("#visTimeSetInputLower").val();
    if (time1 !== '' && time2 !== '') {
        var lower = Date.parse(time1);
        var higher = Date.parse(time2);
        if (lower > higher) {
            $('#timeHighLowWarning').css("display", "block");
            validSetTime = false;
        } else {
            $('#timeHighLowWarning').css("display", "none");
            $('#timeSetWarning').css("display", "none");
            validSetTime = true;
        }
    } else {
        $('#timeSetWarning').css("display", "block");
        $('#timeHighLowWarning').css("display", "none");
        validSetTime = false;
    }
}