$(document).ready(function () {
    alert('worked');
    // ajax call here
});

function callCheck (){
    
    alert(nric.value);
    //Do ajax call
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