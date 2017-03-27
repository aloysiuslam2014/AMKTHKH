var pathToSms = '../Staff/SMS/SMSManagementGateway.ashx';
var smsSendError = "One of the numbers have failed";
var smsSendSuccess = "SMS Sent!";

$(document).ready(function () {
    hideSMSTags();
});

// Validate contact numbers
function checkSMSNumber() {
    var numbers = $("#targetVisitor").val();
    var numArr = numbers.split(' ');
    var valid = true;
    if (numArr.length < 1) {
        numArr = numbers.trim().split(',');
    }
    var uniqueNums = [];
    for (var i = 0; i < numArr.length; i++) {
        var curNum = numArr[i];
        if (curNum != "") {
            if (curNum.charAt(0) == '+' || curNum.charAt(0) != '6') {
                if (uniqueNums.indexOf(curNum) == -1) uniqueNums.push(curNum);
            }
        }
    }
    numbers = "";
    for (i = 0; i < uniqueNums.length; i++) {
        var currentNum = uniqueNums[i]
        if (!validatePhone(currentNum)) {
            valid = false;
        }
        numbers += currentNum + ",";
    }
    $("#targetVisitor").prop('value', numbers.substring(0,numbers.length -1));
    if (valid) {
        checkMessage(uniqueNums);
    } else {
        alert("Invalid Number!");
    }
}

//
function checkMessage(numArr) {
    var message = $("#smsMessage").val();
    if (message === "") {
        $('#emptyMessage').css("display", "block");
    } else {
        $('#emptyMessage').css("display", "none");
        sendSMS(numArr);
    }
}

// Send SMS
function sendSMS(numArr) {
    var numbers = numArr.toString();
    var message = $("#smsMessage").val();
    var headersToProcess = {
        requestType: "sendSMS", message: message, numbers: numbers
    };
    $.ajax({
        url: pathToSms,
        method: 'post',
        data: headersToProcess,

        success: function (returner) {
            var responseArr = returner.split(',');
            if (responseArr.length > 1) {
                alert(smsSendError);
            } else {
                alert(smsSendSuccess);
            }
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