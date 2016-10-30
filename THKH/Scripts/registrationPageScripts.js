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

function CheckIn(nric) {
    var temp = document.getElementById('temp');
    var check = "true";
    var headersToProcess = { nric: nric.value, checkInTruth: check, temperature: temp };
}