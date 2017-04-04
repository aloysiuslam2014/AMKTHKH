var pathToTerminal = './TerminalCalls/TerminalCheckGateway.ashx';

$(document).ready(function () {
    
    $("#myModal").modal({
        backdrop: 'static',
        keyboard: false
    });
     
});


$('#myModal').submit(function (event) {

    // prevent default browser behaviour
    event.preventDefault();

    verifyUser();
});


$('#userNric').keypress(function (e) {
    if (e.which == 13) {
        e.preventDefault();
        //do something   
        updateCheckIn();
    }
});

/// <summary>When a terminal has been selected to be activated. Gets the if from the target 'me'</summary>
function activateMe(me) {
   
    var termName = "";
    var termID = "";
    var nameAndId = me.id.toString().split(":");
    termID = nameAndId.pop();
    termValue.value = termID;
    $(nameAndId).each(function (index, item) {
        termName += item;
    });
    terminalName.textContent = termName;
    
    var headersToProcess = { action: "activate", id: termID };
    $.ajax({
        url: pathToTerminal,
        method: 'post',
        data: headersToProcess,
        success: function (returner) {
            var result = String(returner);
            if (result == "success") {
                activaTab("beginTerminal");
            } else {
                errorMsg.innerText = "The terminal has already been activated elsewhere. Please choose another terminal to activate.";
                $("#alertModal").modal({
                    backdrop: 'static',
                    keyboard: false
                });
                var child = document.getElementById(me.id);
                child.parentElement.removeChild(child);
            }
        },
        error: function (err) {
        },
    });
}

/// <summary>Focuses in the userNric field after selection.</summary>
function activaTab(tab) {
    $(' a[href="#' + tab + '"]').tab('show');
   
    setTimeout(function () { $("#userNric").focus(); },1000);
    
}

/// <summary>Verify's a staff who wants to activate a terminal</summary>
function verifyUser() {
    var headersToProcess = { action: "verify", id: termValue.value, user: usrname.value };
    $.ajax({
        url: pathToTerminal,
        method: 'post',
        data: headersToProcess,
        success: function (returner) {
            var resuts = returner.toString();
            if (String(resuts) == ("success")) {
                userNric.value = "";
                $('#myModal').modal('hide');
            } else {
                launchFail();
            }
        },
        error: function (err) {
        },
    });

}

var exisingTimeouts = "";

/// <summary>Updates a visitors movement into the database</summary>
function updateCheckIn() {

    if ($("#userNric").val() == "deactivate") {
        var headersToProcess = { action: "deactivate", id: termValue.value};
        $.ajax({
            url: pathToTerminal,
            method: 'post',
            data: headersToProcess,
            success: function (returner) {
                var result = String(returner)
                window.location = "./Login.aspx";
                return;
            },
            error: function (err) {
            },
        });
    } else {
        var headersToProcess = { action: "checkIn", id: termValue.value, user: userNric.value.toUpperCase() };
        $.ajax({
            url: pathToTerminal,
            method: 'post',
            data: headersToProcess,
            success: function (returner) {
                $("#userNric").attr("disabled", "disabled");
                if (exisingTimeouts != "")
                    clearTimeout(exisingTimeouts);

                var result = String(returner)
                if (result == "success") {
                    $("#userWelcome").html("Welcome! ");
                    exisingTimeouts = setTimeout(function () { hideWelcome(); }, 500);
                    $("#userWelcome").css('font-size', '12em');
                } else {
                    if (result.split(',')[1] == "locationError") // Successfully found user but he is not suppossed to be there
                    {
                        $("#userWelcome").html("No Entry!<br> Wrong location.");
                        $("#userWelcome").css('color', 'lightcoral');
                    } else if (result == "deactivated") {
                        $("#userWelcome").html("Terminal Has Been deactivated.<br>Refreshing.");
                        $("#userWelcome").css('color', 'lightcoral');
                        location.reload();
                    } else {
                        $("#userWelcome").html("Not Registered!<br> Proceed to front desk.");
                        $("#userWelcome").css('color', 'lightcoral');
                    }
                    exisingTimeouts = setTimeout(function () { hideWelcome(); }, 3000);
                   
                }
               

               
               
            },
            error: function (err) {
            },
        });
    }
    
}

/// <summary>Self explanatory</summary>
function hideWelcome(){
    $("#userWelcome").html('Please Scan Your Card');
    $("#userNric").prop('value', '');
    $("#userNric").removeAttr("disabled");
    $("#userNric").focus();
    $("#userWelcome").css('color', '');
    $("#userWelcome").css('font-size', '4em');
   
}

/// <summary>Self explanatory</summary>
function returnToLogin() {
    
    var goTo = "./Login.aspx";
    document.location.href = goTo;
    
}

/// <summary>Self explanatory</summary>
function launchFail() {
    $("#alertModal").modal({
        backdrop: 'static',
        keyboard: false
    });
}