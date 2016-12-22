// Draggable questions for ordering purposes
$(function () {
    $("#sortable").sortable({
        revert: true
    });
    $("#draggable").draggable({
        connectToSortable: "#sortable",
        helper: "clone",
        revert: "invalid"
    });
    $("ul, li").disableSelection();

    $('#select').change(function () {
        var current = $('#select').val();
        if (current != 'null') {
            $('#select').css('color', 'black');
        } else {
            $('#select').css('color', 'gray');
        }
    });
});

// Show Modal
function showAddQuestionnaireModal() {
    $('#addQuestionnaire').modal('show');
}

// Hide Modal
function hideAddQuestionnaireModal() {
    $('#addQuestionnaire').modal('hide');
}

// Get questionaireList and Question list
function formManagementInit() {
    var resultOfGeneration = "";
    var headersToProcess = {
        requestType: "intialize"
    };
    $.ajax({
        url: './questionaireManagement.ashx',
        method: 'post',
        data: headersToProcess,


        success: function (returner) {
            resultOfGeneration = JSON.parse(returner);
            var res = resultOfGeneration.result;
            if (res.toString() == "success") {
                initialiseData(resultOfGeneration.Msg)
            } else {
                alert(resultOfGeneration.Msg);
            }
        },
        error: function (err) {
            alert(err.Msg);
        },
    });

}

// Inserts the data into the appropriate fields
function initialiseData(data) {
    var qnList = data.qnList; //for qns   --->   qId,question,qnType,values
    
}
//creates options and appends to the field
function fillQuestinaireList(dataForQList) {
    for (var i = 0; i < dataForQList.length; i++) {
        var optin = document.createElement("option");
        $(optin).html(dataForQList[i].ListName);
        if (dataForQList[i].Active.toString() == "1") {
            $(optin).attr("value", "1");
            $(optin).attr("data-color", "info"); 
            $(optin).attr("color", "green");
        }
        $('#qnaires').append(optin);
    }
}



// Select All From Questionaire List of questions
function selectAllInQuestionaireList(table) {
   
}

// Select All From Questions List
function selectAllInQuestionsList(table) {

}

// Add new questionnaire
function newQuestionnaire() {

}

// Delete questionnaire
function deleteQuestionnaire() {

}

// Add Question
function addQuestion() {

}

// Delete Question
function deleteQuestion() {

}

// Add questions to Questionnaire
function AddQtoQuestionnaire() {

}

// Update Questionnaire
function updateQuestionnaire() {

}

// Remove questions from Questionnaire
function removeQFromQuestionnaire() {

}

// set the questionnaire to be active
function setActiveQuestionnaire(){}

// Select all checkboxes
$(document).ready(function () {
    
});