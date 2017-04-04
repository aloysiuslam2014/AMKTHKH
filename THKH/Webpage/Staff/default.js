var loadedTime = false;
var validSetTemp = false;
var validSetTime = false;
var configUrl = '../Staff/MasterConfig/MasterConfigGateway.ashx';


/**
 * First run on script load
 * @param 
 * @return 
 */
$(document).ready(function () {
    $('.nav-tabs a:first').click();
    var trigger = $('.hamburger'),
        overlay = $('.overlay'),
       isClosed = false;

    trigger.click(function () {
        hamburger_cross();
    });

    function hamburger_cross() {

        if (isClosed == true) {
            overlay.hide();
            trigger.removeClass('is-open');
            trigger.addClass('is-closed');
            isClosed = false;
        } else {
            overlay.show();
            trigger.removeClass('is-closed');
            trigger.addClass('is-open');
            isClosed = true;
        }
    }

    $('[data-toggle="offcanvas"]').click(function () {
        $('#wrapper').toggleClass('toggled');
    });
});

/**
 * update configurations
 * @param 
 * @return 
 */
function updateConfig() {
    var username = user;
    var lowTemp = $('#temSetInputLow').val();
    var highTemp = $('#temSetInputHigh').val();
    var warnTemp = $("#temSetInputWarn").val();
    var lowTime = $('#visTimeSetInputLower').val();
    var highTime = $('#visTimeSetInputHigh').val();
    var visLim = $('#visLimInput').val();
    if (lowTemp !== '' & highTemp !== '') {
        validSetTemp = true;
    }
    if (!checkBlankField(lowTime) & !checkBlankField(highTime)) {
        validSetTime = true;
    }
    if (validSetTemp && validSetTime && compareTemp()) {
        var headersToProcess = {
            requestType: "updateSettings", lowTemp: lowTemp, highTemp: highTemp, warnTemp:warnTemp, lowTime: lowTime, highTime: highTime, staffUser: username, visLim: visLim
        };
        $.ajax({
            url: configUrl,
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

/**
 * Updates currently selected Access Profile
 * @param 
 * @return 
 */
function updateAccessProfile() {
    var profileName = $('#permissionProfile').val();
    var permissions = getPermissionSettingsInput();
    if (permissions !== "") {
        var userName = user;
        var headersToProcess = {
            requestType: "updateProfile", profileName: profileName, permissions: permissions, userName: userName
        };
        $.ajax({
            url: configUrl,
            method: 'post',
            data: headersToProcess,

            success: function (returner) {
                var resultOfGeneration = JSON.parse(returner);
                if (resultOfGeneration.Msg == "1") {
                    alert("Profile Saved!");
                    getVisLim();
                    loadFacilities();
                    populateTime();
                } else {
                    alert("Profile Not Saved!");
                }
            },
            error: function (err) {
                alert(err.msg);
            },
        });
    } else {
        alert("You are not allowed to save an empty profile!");
    }
}

/**
 * Creates a new access profile
 * @param 
 * @return 
 */
function newAccessProfile() {
    var profileName = $('#newProfNameInput').val();
    var existProfile = "";
    $('#permissionProfile option').each(function () {
        if (this.innerText == profileName) {
            existProfile = this.value;
        }
    });
    if (existProfile === "") {
        selectNewProfile(profileName);
        hideNewProfileModal();
    } else {
        alert("Profile Already Exists! Please Create a profile with a unique name.");
    }
}

/**
 * Selects newly created questionnaire after adding
 * @param 
 * @return 
 */
function selectNewProfile(name) {
    var optin = document.createElement("option");
    $(optin).attr("name", name);
    $(optin).html(name);
    $(optin).attr("selected", "");
    $('#permissionProfile').append(optin);
    $('.profDrop').css('background', '#aaddff');
}

/**
 * Deletes selected access profile
 * @param 
 * @return 
 */
function delAccessProfile() {
    var profileName = $('#permissionProfile').val();
    var headersToProcess = {
        requestType: "deleteProfile", profileName: profileName
    };
    $.ajax({
        url: configUrl,
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

/**
 * Get current configuration
 * @param 
 * @return 
 */
function getCurrentConfig() {
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
                $('#temSetInputLow').prop('value', arr[0].toString());
                $('#temSetInputHigh').prop('value', arr[1].toString());
                $("#temSetInputWarn").prop('value', arr[2].toString());
                $('#visTimeSetInputLower').val(arr[3].toString());
                $('#visTimeSetInputHigh').val(arr[4].toString());
                $('#visLimInput').val(arr[5].toString());
            }
        },
        error: function (err) {
            alert("Error: " + err.Msg);
        },
    });
}

/**
 * Populates dropdown with all profiles
 * @param 
 * @return 
 */
function fillAccessProfileList() {
    var resultOfGeneration = "";
    var headersToProcess = {
        requestType: "getProfiles"
    };
    $.ajax({
        url: configUrl,
        method: 'post',
        data: headersToProcess,


        success: function (returner) {
            resultOfGeneration = JSON.parse(returner);
            var res = resultOfGeneration.Result;
            if (res.toString() == "Success") {
                var mes = resultOfGeneration.Msg;

                $('#permissionProfile').html("");
                for (var i = 0; i < mes.length; i++) {
                    var optin = document.createElement("option");

                    $(optin).attr("style", "background:white");
                    $(optin).attr("name", mes[i].AccessProfile);
                    $(optin).html(mes[i].AccessProfile);
                    $('#permissionProfile').append(optin);
                }
                getSelectedAccessProfileUser();
            } else {
                alert(resultOfGeneration.Result);
            }
        },
        error: function (err) {
            alert(err.Msg);
        },
    });
}

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
            if (arr.length > 1) {
                visLim = arr[5];
            }
            fillAccessProfileList();
        },
        error: function (err) {
            alert("Error: " + err.Msg);
        },
    });
}

/**
 * Get selected access profile values
 * @param 
 * @return 
 */
function getSelectedAccessProfile() {
    var profile = $('#permissionProfile').val();
    var resultOfGeneration = "";
    var headersToProcess = {
        profileName: profile, requestType: "getSelectedProfile"
    };
    $.ajax({
        url: configUrl,
        method: 'post',
        data: headersToProcess,


        success: function (returner) {
            resultOfGeneration = JSON.parse(returner);
            var res = resultOfGeneration.Result;
            if (res.toString() == "Success") {
                var mes = resultOfGeneration.Msg;

                $('#permissSet').find('input[type=checkbox]:checked').removeAttr('checked');
                for (i = 0; i < mes.length; i++) {
                    var item = mes[i].Permissions.toString();
                    for (j = 0; j < item.length; j++) {
                        var val = item.charAt(j);
                        $("#permissSet input[value='" + val + "']").prop("checked", true);
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

/**
 * Retrive value from checkbox
 * @param 
 * @return 
 */
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

/**
 * Load permissions checkbox
 * @param 
 * @return 
 */
function loadPermissionSettingsField() {
    var headersToProcess = {
        requestType: "getPermissions"
    };
    $.ajax({
        url: '../Staff/UserManagement/UserManagementGateway.ashx',
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
                    htmlString += "<div class='checkbox'><label><input class='perm' type='checkbox' name='" + ids + "' value='" + ids + "'> " + names + "</label></div>";
                }
                var formElement = document.createElement("DIV");
                $(formElement).attr("class", "list-group-item");
                $(formElement).attr("style", "text-align: left");
                $(formElement).attr("data-color", "info");
                $(formElement).html(htmlString);
                $("#permissSet").append(formElement);
            } else {
            }
        },
        error: function (err) {
            alert("Error: " + err.msg + ". Please contact the adminsitrator.");
        },
    });
}

/**
 * populate time fields
 * @param 
 * @return 
 */
function populateSettingsTime() {
    if (!loadedTime) {
        var time = getTimeArray();
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

/**
 * Check lower limit temperature settings
 * @param 
 * @return 
 */
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

/**
 * Check upper limit temperature settings
 * @param 
 * @return 
 */
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

/**
 * Check warning temperature settings
 * @param 
 * @return 
 */
$("#temSetInputWarn").on("input", function () {
    var temper = $("#temSetInputWarn").val();
    if (temper == "") {
        $('#tempSetWarning').css("display", "none");
        $("#tempRangeWarning").css("display", "none");
        $('#tempHighWarnWarning').css("display", "none");
        $("#tempLowWarnWarning").css("display", "none");
    } else {
        try {
            var temperature = parseFloat(temper);
            if (temperature > 34 && temperature < 40) {
                $("#tempRangeWarning").css("display", "none");
                validSetTemp = true;
                compareTemp();
            } else {
                $("#tempRangeWarning").css("display", "block");
                $('#tempHighWarnWarning').css("display", "none");
                $("#tempLowWarnWarning").css("display", "none");
                validSetTemp = false;
            }
        } catch (ex) {
            $('#tempSetWarning').css("display", "block");
            $('#tempHighWarnWarning').css("display", "none");
            $("#tempLowWarnWarning").css("display", "none");
            validSetTemp = false;
        }
    }
});

/**
 * compare temperature fields
 * @param 
 * @return 
 */
function compareTemp() {
    var temp1 = $("#temSetInputLow").val();
    var temp2 = $("#temSetInputHigh").val();
    var tempW = $("#temSetInputWarn").val();
    if (temp1 !== '' && temp2 !== '' && tempW !== '') {
        var low = parseFloat(temp1);
        var high = parseFloat(temp2);
        var warn = parseFloat(tempW);
        if (low > high) {
            $('#tempSetWarning').css("display", "none");
            $("#tempHighLowWarning").css("display", "block");
            $('#tempHighWarnWarning').css("display", "none");
            $("#tempLowWarnWarning").css("display", "none");
            validSetTemp = false;
            return false;
        } else {
            if (low > warn) {
                $('#tempSetWarning').css("display", "none");
                $("#tempHighLowWarning").css("display", "none");
                $('#tempHighWarnWarning').css("display", "none");
                $("#tempLowWarnWarning").css("display", "block");
                validSetTemp = false;
                return false;
            } else if (high < warn) {
                $('#tempSetWarning').css("display", "none");
                $("#tempHighLowWarning").css("display", "none");
                $('#tempHighWarnWarning').css("display", "block");
                $("#tempLowWarnWarning").css("display", "none");
                validSetTemp = false;
                return false;
            }else {
                $('#tempSetWarning').css("display", "none");
                $("#tempHighLowWarning").css("display", "none");
                $('#tempHighWarnWarning').css("display", "none");
                $("#tempLowWarnWarning").css("display", "none");
                validSetTemp = true;
                return true;
            }
        }
    } else {
        validSetTemp = false;
        return false;
    }
}

/**
 * Check upper limit time settings
 * @param 
 * @return 
 */
$("#visTimeSetInputHigh").on("input", function () {
    var time = $("#visTimeSetInputHigh").val();
    if (checkBlankField(time)) {
        $('#timeSetWarning').css("display", "block");
        validSetTime = false;
    } else {
        $('#timeSetWarning').css("display", "none");
        compareTime();
    }
});

/**
 * Check lower limit time settings
 * @param 
 * @return 
 */
$("#visTimeSetInputLower").on("input", function () {
    var time = $("#visTimeSetInputLower").val();
    if (checkBlankField(time)) {
        $('#timeSetWarning').css("display", "block");
        validSetTime = false;
    } else {
        $('#timeSetWarning').css("display", "none");
        compareTime();
    }
});

/**
 * compare time fields
 * @param 
 * @return 
 */
function compareTime() {
    var time1 = $("#visTimeSetInputHigh").val();
    var time2 = $("#visTimeSetInputLower").val();
    if (!checkBlankField(time1) & !checkBlankField(time2)) {
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

/**
 * Hide New Profile Modal
 * @param 
 * @return 
 */
function hideNewProfileModal() {
    $('#newProfileModal').modal('hide');
    $('#newProfNameInput').prop('value', "")
    $('#permissSet').find('input[type=checkbox]:checked').removeAttr('checked');
    showSettingsModalWithNew();
}

/**
 * Show New Profile Modal
 * @param 
 * @return 
 */
function showNewProfileModal() {
    hideSettingsModal();
    $('#newProfileModal').modal({ backdrop: 'static', keyboard: false });
    $('#newProfileModal').modal('show');
}

/**
 * Hide Delete Profile Modal
 * @param 
 * @return 
 */
function hideDelProfileModal() {
    $('#delProfileModal').modal('hide');
    showSettingsModal();
}

/**
 * Show Delete Profile Modal
 * @param 
 * @return 
 */
function showDelProfileModal() {
    hideSettingsModal();
    $('#delProfileModal').modal({ backdrop: 'static', keyboard: false });
    $('#delProfileModal').modal('show');
}

/**
 * Show Settings Modal with New Profile Entry
 * @param 
 * @return 
 */
function showSettingsModalWithNew() {
    $('#settingsModal').modal({ backdrop: 'static', keyboard: false });
    $('#settingsModal').modal('show');
}