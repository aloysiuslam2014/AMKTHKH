// validation of NRIC
function validateNRIC(str) {
    if (str.length != 9)
        return false;

    str = str.toUpperCase();

    var i,
        icArray = [];
    for (i = 0; i < 9; i++) {
        icArray[i] = str.charAt(i);
    }

    icArray[1] = parseInt(icArray[1], 10) * 2;
    icArray[2] = parseInt(icArray[2], 10) * 7;
    icArray[3] = parseInt(icArray[3], 10) * 6;
    icArray[4] = parseInt(icArray[4], 10) * 5;
    icArray[5] = parseInt(icArray[5], 10) * 4;
    icArray[6] = parseInt(icArray[6], 10) * 3;
    icArray[7] = parseInt(icArray[7], 10) * 2;

    var weight = 0;
    for (i = 1; i < 8; i++) {
        weight += icArray[i];
    }

    var offset = (icArray[0] == "T" || icArray[0] == "G") ? 4 : 0;
    var temp = (offset + weight) % 11;

    var st = ["J", "Z", "I", "H", "G", "F", "E", "D", "C", "B", "A"];
    var fg = ["X", "W", "U", "T", "R", "Q", "P", "N", "M", "L", "K"];

    var theAlpha;
    if (icArray[0] == "S" || icArray[0] == "T") { theAlpha = st[temp]; }
    else if (icArray[0] == "F" || icArray[0] == "G") { theAlpha = fg[temp]; }

    return (icArray[8] === theAlpha);
}

// Validation of phone number
function validatePhone(txtPhone) {
    var filter = /^[0-9-+]+$/;
    if (txtPhone.includes('+')) {
        return true;
    }
    if (txtPhone == "") {
        return true;
    }
    if (filter.test(txtPhone)) {
        if ((txtPhone.charAt(0) == '8' || txtPhone.charAt(0) == '6' || txtPhone.charAt(0) == '9') & txtPhone.length == 8) {
            return true;
        }
    }
    return false;
}

// Validation of postal code
function validatePostal(code) {
    var filter = /^[0-9-+]+$/;
    if (code == "") {
        return true;
    }
    if (filter.test(code)) {
         return true;
    }
    return false;
}

// Check for required fields in Assisted Registration page
//function checkRequiredFields() {
//    var valid = true;
//    $.each($("#main input.required"), function (index, value) {
//        if (!$(value).val()) {
//            valid = false;
//        }
//    });
//    if (valid) {
//        $('#emptyFields').css("display", "none");
//        NewAssistReg();
//    }
//    else {
//        $('#emptyFields').css("display", "block");
//    }
//}

//// formats date
//function formatDate(date) {
//    return date.getDay() + "-" + date.getMonth() + "-" + date.getYear();
//}

//// formats date
//function formatTime(date) {
//    var hours = date.getHours();
//    var minutes = date.getMinutes();
//    minutes = minutes < 10 ? '0' + minutes : minutes;
//    var strTime = hours + ':' + minutes;
//    return strTime;
//}