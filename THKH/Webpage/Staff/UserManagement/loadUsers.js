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
        loadPermissionsField();
        getAllUsers();
    } else {
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
            $(listElement).html(data[i].firstName + ' ' + data[i].lastName);

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
                  
                        var checkBox = $(this).parent().find(".hidden");
                        $(checkBox).prop('checked', !$(checkBox).is(':checked'));
                        $(checkBox).triggerHandler('change');
                        if ($(checkBox).is(':checked')) {
                            getUserDetails($(this));  //Get the user details only checkbox is not checked. If deselecting dont get the user
                        } else {
                            clearStaffFields();
                        }
                        updateDisplay($(this));
                  
                });
                $checkbox.on('change', function () {
                    updateDisplay($(this));
                });
            }
            init();
        });
    

}
//Filter the list of available users
function filterUserList(elment) {

    var value = $(elment).val();
    if (value == '' || value == ' ') {
        $('#usersLis > li').show();
        hideQuestionsAppearingInQuestionaire();
    } else {
        $('#usersLis > li:not(:containsi(' + value + '))').hide();
        $('#usersLis > li:containsi(' + value + ')').show();
    }

}

//select all given a target object
function selectAllUsers() {
  
    $("#usersLis li.inactive span").each(function (idx, li) {
            $(li).triggerHandler('click');
        });
    
}
//deselect all from a target list given a keyword
function deSelectAllUsers() {
    $("#usersLis li.active span").each(function (idx, li) {
            $(li).triggerHandler('click');
        });
    
}

//get a selected users details
function getUserDetails(listObj) {
    populateNationalities();
    var headersToProcess = {
        email:$(listObj).attr("id"),
        requestType: "getUser"
    };
    $.ajax({
        url: '../Staff/UserManagement/UserManagement/userManagement.ashx',
        method: 'post',
        data: headersToProcess,

        success: function (returner) {
            var resultOfGeneration = JSON.parse(returner);
            if (resultOfGeneration.Msg == "Success") {
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
                $("#staffAge").val(resultOfGeneration.Result.age);
                $("#staffRace").val(resultOfGeneration.Result.race);
                $("#staffPerms").val(resultOfGeneration.Result.permissions);
                $("#staffTitle").val(resultOfGeneration.Result.position);
            } else {
                alert(resultOfGeneration.Msg);
            }
        },
        error: function (err) {
            alert("Error: " + err.msg + ". Please contact the administrator.");
        },
    });
}

// Update User Data
function updateUser() {
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
    var race = $("#staffRace").val();
    var age = $("#staffAge").val();
    var Email = $("#staffEmail").val();
    var staffTitle = $("#staffTitle").val();
    var staffPwd = $("#staffPwd").val();

    var headersToProcess = {
        fname: fname, lname: lname, snric: snric, address: address, postal: postal, mobtel: mobtel, hometel: hometel, alttel: alttel, sex: sex, nationality: nationality, dob: dob,
        race: race, age: age, email: Email, title: staffTitle, staffPwd: staffPwd,requestType: "addUser"
    };
    $.ajax({
        url: '../Staff/UserManagement/userManagement.ashx',
        method: 'post',
        data: headersToProcess,


        success: function (returner) {
            var resultOfGeneration = JSON.parse(returner);

        },
        error: function (err) {
            alert("Error: " + err.msg + ". Please contact the administrator.");
        },
    });
}

// Delete Selected User
function deleteUser() {
    var snric = $("#staffNric").val();
    var Email = $("#staffEmail").val();
    var headersToProcess = {
        nric: snric, email:Email, requestType: "deleteUser"
    };
    $.ajax({
        url: '../Staff/UserManagement/userManagement.ashx',
        method: 'post',
        data: headersToProcess,


        success: function (returner) {
            var resultOfGeneration = JSON.parse(returner);

        },
        error: function (err) {
            alert("Error: " + err.msg + ". Please contact the administrator.");
        },
    });
}

// Add new user
function addUser() {
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
    var race = $("#staffRace").val();
    var age = $("#staffAge").val();
    var Email = $("#staffEmail").val();
    var staffTitle = $("#staffTitle").val();
    var staffPwd = $("#staffPwd").val();

    var headersToProcess = {
        fname: fname, lname: lname, snric: snric, address: address, postal: postal, mobtel: mobtel, hometel: hometel, alttel: alttel, sex: sex, nationality: nationality, dob: dob,
        race:race, age:age, email:Email, title:staffTitle, permissions:permissions, staffPwd:staffPwd, requestType: "addUser"
    };
    $.ajax({
        url: '../Staff/UserManagement/userManagement.ashx',
        method: 'post',
        data: headersToProcess,


        success: function (returner) {
            var resultOfGeneration = JSON.parse(returner);
            if (resultOfGeneration.Result == "Success") {
                if (resultOfGeneration.Msg == "Success") {
                    // Show Success Modal
                    alert("User Added!");
                }
                // If User exists already, prompt user to click on update instead
            }
        },
        error: function (err) {
            alert("Error: " + err.msg + ". Please contact the adminsitrator.");
        },
    });
}


function clearStaffFields() {
    $('#userInfo .userInput').each(function (idx, obj) {
        $(obj).prop("value", "");

    });
    var update = false;
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
function checkRequiredFieldsUser() {
    var valid = true;
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
        //if (type == "update") {
            //updateUser();
        //} else {
            addUser();
        //}
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
                    htmlString += "<div class='checkbox'><label><input class='perm required userInput' type='checkbox' name='id" + i + "' value='" + ids + "'> " + names + "</label></div>";
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
        format: 'DD-MM-YYYY'
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
    $("#natWarningUser").css("display", "none");
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
    var validPostal = validatePhone($("#staffPostal").val());
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