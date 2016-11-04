$(document).ready(function () {
    
    // ajax call here
});

function callCheck (){
    //Do ajax call

    var nricValue = nric.value;
    var msg;
    var headersToProcess = { nric: nricValue }; //Store objects in this manner 
    $.ajax({
        url: './CheckInOut/checkIn.ashx',
        method: 'post',
        data: headersToProcess,
        
        
        success: function (returner) {
            var resultOfGeneration = JSON.parse(returner);
            if (resultOfGeneration.Result == "Success") {
                DataExists(resultOfGeneration.Msg.split(','));
            } else {
                DataNoExists();
            }
        },
        error: function (err) {
        },
    });
    dataFound = true;
}

function DataExists(arr) {
    var htmStr = "";
    var count = 0;
    arr.forEach(function (element) {
        htmStr += "<br/>" + element
    });
    $('#Details').html(htmStr);
    $('#Details').css("display", "block");
    $('#tempField').css("display", "block");
}

function DataNoExists() {
    $('#Details').html("Visitor Not Found. Please register the visitor.");
}

function CheckIn() {
    var temper = temp.value;
    var check = "true";
    var headersToProcess = { nric: nric.value, temperature: temper };
    $.ajax({
        url: './CheckInOut/checkIn.ashx',
        method: 'post',
        data: headersToProcess,


        success: function (returner) {
            var resultOfGeneration = JSON.parse(returner);
            $('#Details').html(resultOfGeneration.Msg);
            $('#Details').css("display", "block");
        },
        error: function (err) {
        },
    });
    dataFound = true;
}

function NewAssistReg() {
    var fname = document.getElementById("namesInput").value;
    var lname = document.getElementById("lnamesInput").value;
    var snric = document.getElementById("nricsInput").value;
    var address = document.getElementById("addresssInput").value;
    var postal = document.getElementById("postalsInput").value;
    var mobtel = document.getElementById("mobilesInput").value;
    var alttel = document.getElementById("altInput").value;
    var hometel = document.getElementById("homesInput").value;
    var sex = document.getElementById("sexInput").value;
    var nationality = document.getElementById("nationalsInput").value;
    var dob = document.getElementById("datepicker").value;
    var race = "Chinese";
    var age = 23;
    var Email = "hello";

    var headersToProcess = { firstName: fname, lastName: lname, nric: snric, ADDRESS: address, POSTAL: postal, MobTel: mobtel, email: Email, AltTel: alttel, HomeTel: hometel, SEX: sex, Natl: nationality, DOB: dob, RACE: race, AGE: age };
    $.ajax({
        url: './CheckInOut/checkIn.ashx',
        method: 'post',
        data: headersToProcess,


        success: function (returner) {
            var resultOfGeneration = JSON.parse(returner);
            alert(resultOfGeneration.Msg);
        },
        error: function (err) {
        },
    });
}