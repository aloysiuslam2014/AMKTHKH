//var to check if users are already loaded
var loadedUsers = false;
// To check if current process is add user or update user
var newUser = true;
// To check if inputs are valid
var validMobUser = true;
var validAltUser = true;
var validHomUser = true;
var validPosUser = true;

//Load users once
function loadUsersOnce() {
    if (!loadedUsers) {
        hideUserTags();
        fillAccessProfileListUser();
        loadPermissionsField();
        getAllUsers();
        loadedUsers = true;
    } 
}

// Load & Populate User List
function getAllUsers() {
    var headersToProcess = {
        requestType: "loadUsers"
    };
    $.ajax({
        url: '../Staff/UserManagement/userManagement.ashx',
        method: 'post',
        data: headersToProcess,


        success: function (returner) {
            var resultOfGeneration = JSON.parse(returner);
            if (resultOfGeneration.Msg == "Success") {
                initUsersList(resultOfGeneration.Result);
            } else {
                alert(resultOfGeneration.Msg);
            }
        },
        error: function (err) {
            alert("Error: " + err.msg + ". Please contact the administrator.");
        },
    });
}



//Initialize all uers
function initUsersList(data) {
    populateNationalities();
    var target = $("#usersLis");
        //clear existing list objects
    $(target).html("");
    for (var i = 0; i < data.length; i++) {
            var listElement = document.createElement("LI");
            $(listElement).attr("class", "list-group-item");
            $(listElement).attr("data-color", "info");
            
            $(listElement).attr("style", "text-align: left;");
            
            $(listElement).attr("id", data[i].email);
            $(listElement).attr("value", data[i].firstName + ' ' + data[i].lastName);
            $(listElement).html(data[i].firstName + ' ' + data[i].lastName + ' - ' + data[i].email);

            $(target).append(listElement);

        }

    $(target).find('.list-group-item').each(function () {

            // Settings
            var $widget = $(this),
                $checkbox = $('<input type="checkbox" class="hidden" />'),
                color = ($widget.data('color') ? $widget.data('color') : "primary"),
                style = ($widget.data('style') == "button" ? "btn-" : "list-group-item-"),
                settings = {
                    on: {
                        icon: 'glyphicon glyphicon-check'
                    },
                    off: {
                        icon: 'glyphicon glyphicon-unchecked'
                    }
                };

            $widget.css('cursor', 'pointer')
            $widget.append($checkbox);




            // Actions
            function updateDisplay(obj) {
                var isChecked = $(obj).find(".hidden").is(':checked');

                // Set the button's state
                $(obj).data('state', (isChecked) ? "on" : "off");

                // Set the button's icon
                $(obj).find('.state-icon')
                    .removeClass()
                    .addClass('state-icon ' + settings[$(obj).data('state')].icon);

                // Update the button's color
                if (isChecked) {
                    $(obj).addClass(style + color + ' active');
                    $(obj).removeClass(' inactive');
                } else {
                    $(obj).removeClass(style + color + ' active');
                    $(obj).addClass(' inactive');
                }
            }

            // Initialization
            function init() {

                if ($widget.data('checked') == true) {
                    $checkbox.prop('checked', !$checkbox.is(':checked'));
                }

                updateDisplay($widget);

                // Inject the icon if applicable
                if ($widget.find('.state-icon').length == 0) {
                    $widget.prepend('<span class="state-icon ' + settings[$widget.data('state')].icon + '"></span>');
                }


                // Event Handlers

                $widget.on('click', function () {
                    $("#userMode").text("Edit Existing User");
                    $("#newUser").prop('disabled', true);
                    $("#updateUser").prop('disabled', false);
                    $("#staffDOB").prop('readonly', false);
                    $("#staffDOB").prop('disabled', true);
                    getUserDetails($(this));
                });
                $checkbox.on('change', function () {
                    updateDisplay($(this));
                });
            }
            init();
        });
    

}

// get a selected users details
function getUserDetails(listObj) {
    populateNationalities();
    var headersToProcess = {
        email:$(listObj).attr("id"),
        requestType: "getUser"
    };
    $.ajax({
        url: '../Staff/UserManagement/userManagement.ashx',
        method: 'post',
        data: headersToProcess,

        success: function (returner) {
            var resultOfGeneration = JSON.parse(returner);
            if (resultOfGeneration.Msg == "Success") {
                clearStaffFields(false);
                $("#staffEmail").val(resultOfGeneration.Result.email);
                $("#staffFirstName").val(resultOfGeneration.Result.firstName);
                $("#staffLastName").val(resultOfGeneration.Result.lastName);
                $("#staffNric").val(resultOfGeneration.Result.nric);
                $("#staffAddress").val(resultOfGeneration.Result.address);
                $("#staffPostal").val(resultOfGeneration.Result.postalCode);
                $("#staffHomeNum").val(resultOfGeneration.Result.homeTel);
                $("#staffAltNum").val(resultOfGeneration.Result.altTel);
                $("#staffMobileNum").val(resultOfGeneration.Result.mobTel);
                $("#staffSex").val(resultOfGeneration.Result.sex.trim());
                $("#staffNationality").val(resultOfGeneration.Result.nationality);
                $("#staffDOB").val(resultOfGeneration.Result.dateOfBirth);
                var perm = resultOfGeneration.Result.permissions.toString();
                for (i = 0; i < perm.length; i++) {
                    var val = perm.charAt(i)
                    $("#permiss [value='" + val + "']").prop("checked", true);
                }
                $("#staffTitle").val(resultOfGeneration.Result.position);
                $("#permissionProfileDropdown").val(resultOfGeneration.Result.accessProfile);
            } else {
                alert(resultOfGeneration.Msg);
            }
        },
        error: function (err) {
            alert("Error: " + err.Msg + ". Please contact the administrator.");
        },
    });
}

// Update User Data
function updateUser() {
    var username = user;
    var permissions = getPermissionInput();
    var accessProfile = $("#permissionProfileDropdown").val();
    var fname = $("#staffFirstName").val();
    var lname = $("#staffLastName").val();
    var snric = $("#staffNric").val();
    var address = $("#staffAddress").val();
    var postal = $("#staffPostal").val();
    var mobtel = $("#staffMobileNum").val();
    var alttel = $("#staffAltNum").val();
    var hometel = $("#staffHomeNum").val();
    var sex = $("#staffSex").val();
    var nationality = $("#staffNationality").val();
    var dob = $("#staffDOB").val();
    var Email = $("#staffEmail").val();
    var staffTitle = $("#staffTitle").val();
    var staffPwd = $("#staffPwd").val();

    var headersToProcess = {
        username: username, fname: fname, lname: lname, snric: snric, address: address, postal: postal, mobtel: mobtel, hometel: hometel, alttel: alttel, sex: sex, nationality: nationality, dob: dob,
        email: Email, title: staffTitle, permissions: permissions, staffPwd: staffPwd, requestType: "updateUser", accessProfile: accessProfile
    };
    $.ajax({
        url: '../Staff/UserManagement/userManagement.ashx',
        method: 'post',
        data: headersToProcess,


        success: function (returner) {
            var resultOfGeneration = JSON.parse(returner);
            if (resultOfGeneration.Result == "Success") {
                if (resultOfGeneration.Msg == "1" || resultOfGeneration.Msg == "2") {
                    showUpdateUserSuccessModal(resultOfGeneration.Msg);
                    clearStaffFields(true);
                }
            } else {
                // Error
                alert("Error: " + resultOfGeneration.Msg);
            }
        },
        error: function (err) {
            alert("Error: " + err.Msg + ". Please contact the administrator.");
        },
    });
}

// Add new user
function addUser() {
    var username = user;
    var permissions = getPermissionInput();
    var fname = $("#staffFirstName").val();
    var lname = $("#staffLastName").val();
    var snric = $("#staffNric").val();
    var address = $("#staffAddress").val();
    var postal = $("#staffPostal").val();
    var mobtel = $("#staffMobileNum").val();
    var alttel = $("#staffAltNum").val();
    var hometel = $("#staffHomeNum").val();
    var sex = $("#staffSex").val();
    var nationality = $("#staffNationality").val();
    var dob = $("#staffDOB").val();
    var Email = $("#staffEmail").val();
    var staffTitle = $("#staffTitle").val();
    var staffPwd = $("#staffPwd").val();
    var accessProfile = $("#permissionProfileDropdown").val();

    var headersToProcess = {
        username:username, fname: fname, lname: lname, snric: snric, address: address, postal: postal, mobtel: mobtel, hometel: hometel, alttel: alttel, sex: sex, nationality: nationality, dob: dob,
        email:Email, title:staffTitle, permissions:permissions, staffPwd:staffPwd, requestType: "addUser", accessProfile: accessProfile
    };
    $.ajax({
        url: '../Staff/UserManagement/userManagement.ashx',
        method: 'post',
        data: headersToProcess,


        success: function (returner) {
            var resultOfGeneration = JSON.parse(returner);
            if (resultOfGeneration.Result == "Success") {
                if (resultOfGeneration.Msg == "Success") {
                    showAddUserSuccessModal();
                    getAllUsers();
                    hideUserTags();
                    clearStaffFields(true);
                }
            } else {
                // Error
            }
        },
        error: function (err) {
            alert("Error: " + err.msg + ". Please contact the administrator.");
        },
    });
}


function clearStaffFields(newUser) {
    $('#userInfo .userInput').each(function (idx, obj) {
        if ($(obj).attr("type") !== "checkbox") {
            $(obj).prop("value", "");
            $(obj).css('background', '#ffffff');
        }
    });
    var update = false;
    if (newUser) {
        $("#staffEmail").prop('readonly', false);
        $("#userMode").text("Create New User");
        $("#newUser").prop('disabled', false);
        $("#updateUser").prop('disabled', true);
        hideUserTags();
    } else {
        $("#staffEmail").prop('readonly', true);
        $("#newUser").prop('disabled', true);
        $("#updateUser").prop('disabled', false);
    }
    $("#staffDOB").prop('readonly', true);
    $("#staffDOB").prop('disabled', false);
    $('#permiss').find('input[type=checkbox]:checked').removeAttr('checked');
}

// Retrive value from checkbox
function getPermissionInput() {
    var permissions = "";
    $("#permiss .perm").each(function (index, value) {
        var element = $(this);
        var val = $(value).attr('value');
        var check = element.is(":checked");
        if (check) {
            permissions += val;
        }
    });
    return permissions;
}

// For field validations
function checkRequiredFieldsUser(type) {
    var valid = true;
    if (type == "update") {
        $('#staffPwd').removeClass('required');
    }
    $.each($("#userInfo input.required"), function (index, value) {
        var element = $(value).val();
        if (!element || element == "") {
            valid = false;
            $(value).css('background', '#f3f78a');
        }
    });
    if (!validMobUser || !validHomUser || !validAltUser || !validPosUser || !checkNationalsUser()) {
        valid = false;
    }
    if (valid) {
        $('#emptyUserFields').css("display", "none");
        if (type == "update") {
            updateUser();
        } else {
            addUser();
        }
    }
    else {
        $('#emptyUserFields').css("display", "block");
    }
}

// Populates Nationality Field
function populateNationalities() {
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
            $(optin).attr("value", nationalities[i].toUpperCase());
            $(optin).html(nationalities[i]);
            $('#staffNationality').append(optin);
    }
}

// Populates dropdown with all profiles
function fillAccessProfileListUser() {
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
                $('#permissionProfileDropdown').html("");
                for (var i = 0; i < mes.length; i++) {
                    var optin = document.createElement("option");

                    $(optin).attr("style", "background:white");
                    $(optin).attr("name", mes[i].AccessProfile);
                    $(optin).html(mes[i].AccessProfile);
                    $('#permissionProfileDropdown').append(optin);
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

// Get selected access profile values
function getSelectedAccessProfileUser() {
    var profile = $('#permissionProfileDropdown').val();
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
                $('#permiss').find('input[type=checkbox]:checked').removeAttr('checked');
                for (i = 0; i < mes.length; i++) {
                    var item = mes[i].Permissions.toString();
                    for (j = 0; j < item.length; j++) {
                        var val = item.charAt(j);
                        $("#permiss input[value='" + val + "']").prop("checked", true);
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

function loadPermissionsField() {
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
                    htmlString += "<div class='checkbox'><label><input class='perm required userInput' type='checkbox' name='id" + i + "' value='" + ids + "' disabled> " + names + "</label></div>";
                }
                var formElement = document.createElement("DIV");
                $(formElement).attr("class", "list-group-item");
                $(formElement).attr("style", "text-align: left");
                $(formElement).attr("data-color", "info");
                $(formElement).attr("id", 17);
                $(formElement).html(htmlString);
                $("#permiss").append(formElement);
            } else {
                // Error Msg here
            }
        },
        error: function (err) {
            alert("Error: " + err.msg + ". Please contact the adminsitrator.");
        },
    });
}

// Datetime Picker JQuery
$(function () {
    $('#staffDOBDiv').datetimepicker({
        // dateFormat: 'dd-mm-yy',
        defaultDate: new Date(),
        maxDate: 'now',
        format: 'DD-MM-YYYY',
        ignoreReadonly: true
    });
});

// hide all warnings on page load
function hideUserTags() {
    $("#emptyUserFields").css("display", "none");
    $("#altWarningUser").css("display", "none");
    $("#emptyNricWarningUser").css("display", "none");
    $("#nricWarningUser").css("display", "none");
    $("#mobWarningUser").css("display", "none");
    $("#posWarningUser").css("display", "none");
    $("#homWarningUser").css("display", "none");
    $("#altWarningUser").css("display", "none");
    $("#emailWarningUser").css("display", "none");
    $("#natWarningUser").css("display", "none");
    $("#updateUser").prop('disabled', true);
}

// Check nationality input field
function checkNationalsUser() {
    if ($("#staffNationality").val() == "") {
        $("#natWarningUser").css("display", "block");
        return false;
    } else {
        $("#natWarningUser").css("display", "none");
    }
    return true;
}

// Validate NRIC format
$("#staffNric").on("input", function () {
    if ($("#staffNric").val() == "") {
        $("#emptyNricWarningUser").css("display", "block");
        $("#nricWarningUser").css("display", "none");
    }else{
        var validNric = validateNRIC($("#staffNric").val());
        if (validNric !== false) {
            $("#emptyNricWarningUser").css("display", "none");
            $("#nricWarningUser").css("display", "none");
        } else {
            $("#nricWarningUser").css("display", "block");
            $("#emptyNricWarningUser").css("display", "none");
        }
    }
});

// Email Format Validation
$("#staffEmail").on("input", function () {
    var email = $("#staffEmail").val();
    if (/^\w+([\.-]?\w+)*@\w+([\.-]?\w+)*(\.\w{2,3})+$/.test(email)) {
        $("#emailWarningUser").css("display", "none");
        validEmail = true;
    } else {
        $("#emailWarningUser").css("display", "block");
        validEmail = false;
    }
});

// Validate mobile phone number format
$("#staffMobileNum").on("input", function () {
    var validPhone = validatePhone($("#staffMobileNum").val());
    if (validPhone !== false) {
        $("#mobWarningUser").css("display", "none");
        validMobUser = true;
    } else {
        $("#mobWarningUser").css("display", "block");
        validMobUser = false;
    }
});

// Validate postal code number format
$("#staffPostal").on("input", function () {
    var validPostal = validatePostal($("#staffPostal").val());
    if (validPostal !== false) {
        $("#posWarningUser").css("display", "none");
        validPosUser = true;
    } else {
        $("#posWarningUser").css("display", "block");
        validPosUser = false;
    }
});

// Validate home phone number format
$("#staffHomeNum").on("input", function () {
    var validPhone = validatePhone($("#staffHomeNum").val());
    if (validPhone !== false) {
        $("#homWarningUser").css("display", "none");
        validHomUser = true;
    } else {
        $("#homWarningUser").css("display", "block");
        validHomUser = false;
    }
});

// Validate alt phone number format
$("#staffAltNum").on("input", function () {
    var validPhone = validatePhone($("#staffAltNum").val());
    if (validPhone !== false) {
        $("#altWarningUser").css("display", "none");
        validAltUser = true;
    } else {
        $("#altWarningUser").css("display", "block");
        validAltUser = false;
    }
});

// Show Success Modal
function showAddUserSuccessModal() {
    $('#addUserSuccessModal').modal('show');
    $('#addUserSuccessModal').modal({ backdrop: 'static', keyboard: false });
}

// Hide Success Modal
function hideAddUserSuccessModal() {
    $('#addUserSuccessModal').modal('hide');
}

// Show Success Modal
function showUpdateUserSuccessModal(text) {
    if (text == "1") {
        $("#updateUserTextDiv").text("User information and password updated!");
    }
    $('#updateUserSuccessModal').modal('show');
    $('#updateUserSuccessModal').modal({ backdrop: 'static', keyboard: false });
}

// Hide Success Modal
function hideUpdateUserSuccessModal() {
    $('#updateUserSuccessModal').modal('hide');
}

// Email Format Validation
function ValidateEmail() {
    var email = $('#staffEmail').val();
    if (/^\w+([\.-]?\w+)*@\w+([\.-]?\w+)*(\.\w{2,3})+$/.test(email)) {
        return true;
    }
    return false;
}
