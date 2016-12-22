﻿// Show Modal
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
        requestType: "initialize"
    };
    $.ajax({
        url: '../Staff/QuestionaireManagement/questionaireManagement.ashx',
        method: 'post',
        data: headersToProcess,


        success: function (returner) {
            resultOfGeneration = JSON.parse(returner);
            var res = resultOfGeneration.Result;
            if (res.toString() == "Success") {
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

// Inserts the data into the appropriate fields <Populate Dropdown List>
function initialiseData(data) {
    var qnList = data.qnList;
    for(var i = 0; i< qnList.length;i++){
        // If active, append a "Active" to the Form ID
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
        url: '../Staff/QuestionaireManagement/questionaireManagement.ashx',
        method: 'post',
        data: headersToProcess,


        success: function (returner) {
            resultOfGeneration = JSON.parse(returner);
            if (resultOfGeneration.Result === "Success") {
                alert("Questionnaire " + qname + " Added!");
                hideAddQuestionnaireModal();
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
        url: '../Staff/QuestionaireManagement/questionaireManagement.ashx',
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
        url: '../Staff/QuestionaireManagement/questionaireManagement.ashx',
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
        url: '../Staff/QuestionaireManagement/questionaireManagement.ashx',
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
        url: '../Staff/QuestionaireManagement/questionaireManagement.ashx',
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