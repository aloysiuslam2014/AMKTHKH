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

// Updates currently selected Access Profile
function updateAccessProfile() {
    var permissions = getPermissionSettingsInput();
    //var selectedProfile = "";
}

// Creates a new access profile
function newAccessProfile() {

}

// Deletes selected access profile
function delAccessProfile() {

}

// Get current configuration
function getCurrentConfig() {
    var headersToProcess = {
        requestType: "getConfig"
    };
    $.ajax({
        url: '../Staff/MasterConfig/masterConfig.ashx',
        method: 'post',
        data: headersToProcess,


        success: function (returner) {
            var resultOfGeneration = JSON.parse(returner);
            var mes = resultOfGeneration.Msg;
            var arr = mes.toString().split(",");
            if (arr.length > 1) {
                $('#temSetInputLow').prop('value', arr[0].toString());
                $('#temSetInputHigh').prop('value', arr[1].toString());
                $('#visTimeSetInputLower').val(arr[2].toString());
                $('#visTimeSetInputHigh').val(arr[3].toString());
            }
            //for (i = 0; i < perm.length; i++) {
            //    $("#permissSet [value='" + perm.charAt(i) + "']").prop("checked", true);
            //}
        },
        error: function (err) {
            alert("Error: " + err.Msg);
        },
    });
}

// Retrive value from checkbox
function getPermissionSettingsInput() {
    var permissions = "";
    $("#permissSet .perm").each(function (index, value) {
        var element = $(this);
        var val = $(value).attr('value');
        var check = element.is(":checked");
        if (check) {
            permissions += val;
        }
    });
    return permissions;
}

// Load permissions checkbox
function loadPermissionSettingsField() {
    var headersToProcess = {
        requestType: "getPermissions"
    };
    $.ajax({
        url: '../Staff/UserManagement/userManagement.ashx',
        method: 'post',
        data: headersToProcess,


        success: function (returner) {
            var resultOfGeneration = JSON.parse(returner);
            if (resultOfGeneration.Msg == "Success") {
                var result = resultOfGeneration.Result;
                var htmlString = "";
                for (i = 0; i < result.length; i++) {
                    var ids = result[i].accessID;
                    var names = result[i].accessName;
                    htmlString += "<div class='checkbox'><label><input class='perm required userInput' type='checkbox' name='id" + i + "' value='" + ids + "'> " + names + "</label></div>";
                }
                var formElement = document.createElement("DIV");
                $(formElement).attr("class", "list-group-item");
                $(formElement).attr("style", "text-align: left");
                $(formElement).attr("data-color", "info");
                $(formElement).attr("id", 17);
                $(formElement).html(htmlString);
                $("#permissSet").append(formElement);
            } else {
                // Error Msg here
            }
        },
        error: function (err) {
            alert("Error: " + err.msg + ". Please contact the adminsitrator.");
        },
    });
}

// populate time fields
function populateSettingsTime() {
    if (!loadedTime) {
        var time = [
                '00:00',
                '00:30',
                '01:30',
                '02:00',
                '02:30',
                '03:00',
                '03:30',
                '04:00',
                '04:30',
                '05:00',
                '05:30',
                '06:00',
                '06:30',
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
                '21:30',
                '22:00',
                '22:30',
                '23:00',
                '23:30'];
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