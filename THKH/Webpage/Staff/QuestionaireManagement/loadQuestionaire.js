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
    var qnList = data.qnList;
    for(var i = 0; i< qnList.length;i++){

    }
}

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
});

// Select All From Questionaire List of questions
function selectAllInQuestionaireList(table) {
   
}

// Select All From Questions List
function selectAllInQuestionsList(table) {

}

// Add new questionnaire
function newQuestionnaire() {
    var resultOfGeneration = "";
    var qname = $("#qnaireid").val();
    var headersToProcess = {
        requestType: "addQuestionnaire", qName: qname
    };
    $.ajax({
        url: './questionaireManagement.ashx',
        method: 'post',
        data: headersToProcess,


        success: function (returner) {
            resultOfGeneration = JSON.parse(returner);
            if (resultOfGeneration.Result === "Success") {
                alert("Questionnaire " + qname + " Added!");
            } else {
                alert("Questionnaire name already exists! Please use a unique name.");
            }
        },
        error: function (err) {
            alert(err.Msg);
        },
    });

}

// Delete questionnaire
function deleteQuestionnaire() {
    var resultOfGeneration = "";
    var headersToProcess = {
        requestType: "deleteQuestionnaire"
    };
    $.ajax({
        url: './questionaireManagement.ashx',
        method: 'post',
        data: headersToProcess,


        success: function (returner) {
            resultOfGeneration = JSON.parse(returner);
            var res = resultOfGeneration.Msg;

        },
        error: function (err) {
            alert(err.Msg);
        },
    });

}

// Add Question
function addQuestion() {
    var resultOfGeneration = "";
    var headersToProcess = {
        requestType: "addQuestion"
    };
    $.ajax({
        url: './questionaireManagement.ashx',
        method: 'post',
        data: headersToProcess,


        success: function (returner) {
            resultOfGeneration = JSON.parse(returner);
            var res = resultOfGeneration.Msg;

        },
        error: function (err) {
            alert(err.Msg);
        },
    });

}

// Delete Question
function deleteQuestion() {
    var resultOfGeneration = "";
    var headersToProcess = {
        requestType: "deleteQuestion"
    };
    $.ajax({
        url: './questionaireManagement.ashx',
        method: 'post',
        data: headersToProcess,


        success: function (returner) {
            resultOfGeneration = JSON.parse(returner);
            var res = resultOfGeneration.Msg;

        },
        error: function (err) {
            alert(err.Msg);
        },
    });

}

// Add questions to Questionnaire
function AddQtoQuestionnaire() {
    // May not need
}

// Update Questionnaire
function updateQuestionnaire() {
    var resultOfGeneration = "";
    var headersToProcess = {
        requestType: "update"
    };
    $.ajax({
        url: './questionaireManagement.ashx',
        method: 'post',
        data: headersToProcess,


        success: function (returner) {
            resultOfGeneration = JSON.parse(returner);
            var res = resultOfGeneration.Msg;

        },
        error: function (err) {
            alert(err.Msg);
        },
    });

}

// Remove questions from Questionnaire
function removeQFromQuestionnaire() {
    // May not need
}

// Checkbox
$(function () {
    $('.list-group.checked-list-box .list-group-item').each(function () {

// Select all checkboxes
$(document).ready(function () {
    
});