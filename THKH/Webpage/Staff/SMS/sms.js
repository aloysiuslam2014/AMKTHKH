// Validate contact numbers
function checkNumber() {
    var numbers = $("#targetVisitor").val();
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
            var resultOfGeneration = JSON.parse(returner);
            
        },
        error: function (err) {
            alert(err.msg);
        },
    });
}