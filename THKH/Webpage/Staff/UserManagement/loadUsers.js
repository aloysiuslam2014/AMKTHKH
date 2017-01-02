//var to check if users are already loaded
var loadedUsers = false;
//Load users once
function loadUsersOnce() {
    if (!loadedUsers) {
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
        url: './UserManagement/userManagement.ashx',
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
            alert("Error: " + err.msg + ". Please contact the adminsitrator.");
        },
    });
}



//Initialize all uers
function initUsersList(data) {
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
    var headersToProcess = {
        email:$(listObj).attr("id"),
        requestType: "getUser"
    };
    $.ajax({
        url: './UserManagement/userManagement.ashx',
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
            alert("Error: " + err.msg + ". Please contact the adminsitrator.");
        },
    });
}
// Update User Data
function updateUser() {
    var headersToProcess = {
        pName: pName, bedno: bedno, requestType: "updateUser"
    };
    $.ajax({
        url: './userManagement.ashx',
        method: 'post',
        data: headersToProcess,


        success: function (returner) {
            var resultOfGeneration = JSON.parse(returner);

        },
        error: function (err) {
            alert("Error: " + err.msg + ". Please contact the adminsitrator.");
        },
    });
}

// Delete Selected User
function deleteUser() {
    var headersToProcess = {
        pName: pName, bedno: bedno, requestType: "deleteUser"
    };
    $.ajax({
        url: './userManagement.ashx',
        method: 'post',
        data: headersToProcess,


        success: function (returner) {
            var resultOfGeneration = JSON.parse(returner);

        },
        error: function (err) {
            alert("Error: " + err.msg + ". Please contact the adminsitrator.");
        },
    });
}

// Add new user
function addUser() {
    var headersToProcess = {
        pName: pName, bedno: bedno, requestType: "addUser"
    };
    $.ajax({
        url: './userManagement.ashx',
        method: 'post',
        data: headersToProcess,


        success: function (returner) {
            var resultOfGeneration = JSON.parse(returner);

        },
        error: function (err) {
            alert("Error: " + err.msg + ". Please contact the adminsitrator.");
        },
    });
}
