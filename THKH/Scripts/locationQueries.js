$(document).ready(function () {
    $('#navigatePage a:first').tab('show');
  
   
     
});

$("#myModal").modal({
    backdrop: 'static',
    keyboard: false
});
$('#myModal').submit(function (event) {

    // prevent default browser behaviour
    event.preventDefault();

    verifyUser();
});


function activateMe(me) {
   
    var nameAndId = me.id.toString().split(":");
    terminalName.textContent = nameAndId[0];
    termValue.value = nameAndId[1];
    var headersToProcess = { action: "activate", id: nameAndId[1] };
    $.ajax({
        url: './TerminalCalls/TerminalCheck.ashx',
        method: 'post',
        data: headersToProcess,
        success: function (returner) {
            var result = String(returner);
            if (result == "success") {
                activaTab("beginTerminal");
            } else {
                errorMsg.innerText = "The terminal has already been activated elsewhere. Please refresh the page to view the latest list of terminals available.";
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

function activaTab(tab) {
    $(' a[href="#' + tab + '"]').tab('show');
   
    setTimeout(function () { $("#userNric").focus(); },1000);
    
}

function verifyUser() {
    var headersToProcess = { action: "verify", id: termValue.value, user: usrname.value };
    $.ajax({
        url: './TerminalCalls/TerminalCheck.ashx',
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

function launchFail() {
    $("#alertModal").modal({
        backdrop: 'static',
        keyboard: false
    });
}