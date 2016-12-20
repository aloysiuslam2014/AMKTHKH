//// Loads & displays the active questionnaire from the DB for Assisted Reg
//function loadAssistedActiveForm() {
//    var headersToProcess = {
//        requestType: "form"
//    };
//    $.ajax({
//        url: './CheckInOut/checkIn.ashx',
//        method: 'post',
//        data: headersToProcess,


//        success: function (returner) {
//            var resultOfGeneration = JSON.parse(returner);
//            // Display Form CSS
//        },
//        error: function (err) {
//        },
//    });
//}

//// Loads & displays the active questionnaire from the DB for Self-Reg
//function loadSelfActiveForm() {
//    var resultOfGeneration = "";
//    var headersToProcess = {
//        requestType: "form"
//    };
//    $.ajax({
//        url: '../Staff/CheckInOut/checkIn.ashx',
//        method: 'post',
//        data: headersToProcess,


//        success: function (returner) {
//            resultOfGeneration = JSON.parse(returner);
//            // Display Form CSS
//        },
//        error: function (err) {
//            alert(err.Msg);
//        },
//    });
//}

// Show Modal
function showAddQuestionnaireModal() {
    $('#addQuestionnaire').modal('show');
}

// Hide Modal
function hideAddQuestionnaireModal() {
    $('#addQuestionnaire').modal('hide');
}