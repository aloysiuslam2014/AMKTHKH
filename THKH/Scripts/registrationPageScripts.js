$(document).ready(function () {
    
    // ajax call here
});

function callCheck (){
    
    alert(nric.value);
    //Do ajax call
    var headersToProcess = {  messages: "Hi i was sent to and back" }; //Store objects in this manner 
    var nricValue = nric.value.toString;

    $.ajax({
        url: './CheckInOut/checkIn.ashx',
        method: 'post',
        data: headersToProcess,
        
        
        success: function (returner) {
            var resultOfGeneration = JSON.parse(returner);
            if (resultOfGeneration.Result == "Success") {
                alert(resultOfGeneration.Msg);
            }
        },
        error: function (err) {
        },
    });
    dataFound = true;
    //If data was returned , populate the text area and reveal temp box else declare that user not found
    if (dataFound) {
        obj = $('#tempField')
        obj.css("display", "block");
        alert(nric.value);
    } else {
        $('#Details').innerHTML = "Visitor Not Found. Please register the visitor.";
    }
}