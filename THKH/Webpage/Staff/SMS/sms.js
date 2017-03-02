$(document).ready(function () {
    hideSMSTags();
});

// Validate contact numbers
function checkSMSNumber() {
    var numbers = $("#targetVisitor").val();
    var numArr = numbers.split(',');
    // Some format check here
    checkMessage();
}

function checkMessage() {
    var message = $("#smsMessage").val();
    if (message === "") {
        $('#emptyMessage').css("display", "block");
    } else {
        $('#emptyMessage').css("display", "none");
        sendSMS();
    }
}

// Send SMS
function sendSMS() {
    var numbers = $("#targetVisitor").val();
    var message = $("#smsMessage").val();
    var headersToProcess = {
        requestType: "sendSMS", message: message, numbers: numbers
    };
    $.ajax({
        url: '../Staff/SMS/SMSManagement.ashx',
        method: 'post',
        data: headersToProcess,

        success: function (returner) {
            //var resultOfGeneration = JSON.parse(returner);
            var responseArr = returner.split(',');
        },
        error: function (err) {
            alert(err.msg);
        },
    });
}

// Hide all tags
function hideSMSTags() {
    $('#invalidSMSNumber').css("display", "none");
    $('#emptyMessage').css("display", "none");
}