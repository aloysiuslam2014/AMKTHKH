// Logic to get temp range & time range & send to ashx
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
            },
            error: function (err) {
                alert(err.msg);
            },
        });
    }
}

// Updates currently selected Access Profile
function updateAccessProfile() {
    var profileName = $('#permissionProfile').val();
    var permissions = getPermissionSettingsInput();
    var userName = user;
    var headersToProcess = {
        requestType: "updateProfile", profileName: profileName, permissions: permissions, userName: userName
    };
    $.ajax({
        url: '../Staff/MasterConfig/masterConfig.ashx',
        method: 'post',
        data: headersToProcess,

        success: function (returner) {
            var resultOfGeneration = JSON.parse(returner);
            if (resultOfGeneration.Msg == "1") {
                alert("Profile Saved!");
            } else {
                alert("Profile Not Saved!");
            }
        },
        error: function (err) {
            alert(err.msg);
        },
    });
}

// Creates a new access profile
function newAccessProfile() {
    var profileName = $('#newProfNameInput').val();
    selectNewProfile(profileName);
    hideNewProfileModal();
}

// Selects newly created questionnaire after adding
function selectNewProfile(name) {
    var optin = document.createElement("option");
    $(optin).attr("name", name);
    $(optin).html(name);
    $(optin).attr("selected", "");
    $('#permissionProfile').append(optin);
    $('.profDrop').css('background', '#aaddff');
}

// Deletes selected access profile
function delAccessProfile() {
    var profileName = $('#permissionProfile').val();
    var headersToProcess = {
        requestType: "deleteProfile", profileName: profileName
    };
    $.ajax({
        url: '../Staff/MasterConfig/masterConfig.ashx',
        method: 'post',
        data: headersToProcess,

        success: function (returner) {
            var resultOfGeneration = JSON.parse(returner);
            if (resultOfGeneration.Msg == "1") {
                hideDelProfileModal();
                alert("Profile Deleted!");
            } else {
                hideDelProfileModal();
                alert("Profile Not Deleted!");
            }
        },
        error: function (err) {
            alert(err.msg);
        },
    });
}

// Populates dropdown with all profiles
function fillAccessProfileList() {
    var resultOfGeneration = "";
    var headersToProcess = {
        requestType: "getProfiles"
    };
    $.ajax({
        url: '../Staff/MasterConfig/masterConfig.ashx',
        method: 'post',
        data: headersToProcess,


        success: function (returner) {
            resultOfGeneration = JSON.parse(returner);
            var res = resultOfGeneration.Result;
            // Some array here
            if (res.toString() == "Success") {
                var mes = resultOfGeneration.Msg;

                //clear existing options
                $('#permissionProfile').html("");
                for (var i = 0; i < mes.length; i++) {
                    var optin = document.createElement("option");

                    $(optin).attr("style", "background:white");
                    $(optin).attr("name", mes[i].AccessProfile);
                    $(optin).html(mes[i].AccessProfile);
                    $('#permissionProfile').append(optin);
                }
                getSelectedAccessProfile();
            } else {
                alert(resultOfGeneration.Result);
            }
        },
        error: function (err) {
            alert(err.Msg);
        },
    });
}

// Get selected access profile values
function getSelectedAccessProfile() {
    var profile = $('#permissionProfile').val();
    var resultOfGeneration = "";
    // Get name of selected profile
    var headersToProcess = {
        profileName: profile, requestType: "getSelectedProfile"
    };
    $.ajax({
        url: '../Staff/MasterConfig/masterConfig.ashx',
        method: 'post',
        data: headersToProcess,


        success: function (returner) {
            resultOfGeneration = JSON.parse(returner);
            var res = resultOfGeneration.Result;
            // Some array here
            if (res.toString() == "Success") {
                var mes = resultOfGeneration.Msg;

                //clear existing options
                $('#permissSet').find('input[type=checkbox]:checked').removeAttr('checked');

                for (i = 0; i < mes.length; i++) {
                    var item = mes[i].Permissions.toString();
                    for (j = 0; j < item.length; j++) {
                        var val = item.charAt(j);
                        $("#permissSet input[name='" + val + "'][value='" + val + "']").prop("checked", true);
                    }
                }
            } else {
                alert(resultOfGeneration.Result);
            }
        },
        error: function (err) {
            alert(err.Msg);
        },
    });
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
            fillAccessProfileList();
            if (arr.length > 1) {
                $('#temSetInputLow').prop('value', arr[0].toString());
                $('#temSetInputHigh').prop('value', arr[1].toString());
                $('#visTimeSetInputLower').val(arr[2].toString());
                $('#visTimeSetInputHigh').val(arr[3].toString());
            }
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
                $("#permissSet").html("");
                for (i = 0; i < result.length; i++) {
                    var ids = result[i].accessID;
                    var names = result[i].accessName;
                    htmlString += "<div class='checkbox'><label><input class='perm required userInput' type='checkbox' name='" + ids + "' value='" + ids + "'> " + names + "</label></div>";
                }
                var formElement = document.createElement("DIV");
                $(formElement).attr("class", "list-group-item");
                $(formElement).attr("style", "text-align: left");
                $(formElement).attr("data-color", "info");
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

// Hide New Profile Modal
function hideNewProfileModal() {
    $('#newProfileModal').modal('hide');
    $('#newProfNameInput').prop('value', "")
    //clear existing options
    $('#permissSet').find('input[type=checkbox]:checked').removeAttr('checked');
    showSettingsModalWithNew();
}

// Show New Profile Modal
function showNewProfileModal() {
    hideSettingsModal();
    $('#newProfileModal').modal({ backdrop: 'static', keyboard: false });
    $('#newProfileModal').modal('show');
}

// Hide Delete Profile Modal
function hideDelProfileModal() {
    $('#delProfileModal').modal('hide');
    showSettingsModal();
}

// Show Delete Profile Modal
function showDelProfileModal() {
    hideSettingsModal();
    $('#delProfileModal').modal({ backdrop: 'static', keyboard: false });
    $('#delProfileModal').modal('show');
}

// Show Settings Modal with New Profile Entry
function showSettingsModalWithNew() {
    $('#settingsModal').modal({ backdrop: 'static', keyboard: false });
    $('#settingsModal').modal('show');
}