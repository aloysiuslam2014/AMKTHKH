$(document).ready(function () {
    
    // ajax call here
});

function callCheck (){
    
    alert(nric.value);
    //Do ajax call
    var headersToProcess = { xAxis: xAxsList, yAxis: yAxsList, chartType: getChartObj.id };//Store objects in this manner 
    $.ajax({
        url: 'generateReport.ashx',
        method: 'post',
        dataType: 'text',//JSON.parse
        contentType: false,
        processData: false,
        success: function (returner) {
            var resultOfGeneration = JSON.parse(returner);
            if (resultOfGeneration.Result == "Error") {
    
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