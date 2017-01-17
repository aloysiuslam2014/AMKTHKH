//create a case insensitive jquery contains method
$.extend($.expr[':'], {
    'containsi': function (elem, i, match, array) {
        return (elem.textContent || elem.innerText || '').toLowerCase()
            .indexOf((match[3] || "").toLowerCase()) >= 0;
    }
});

//if the user clicked the qn edit button or not. To prevent li from activating if the edit button was pressed
var notEditing = true;
//To determine if the user is selected edit or create
var isCreateQn = false;
//When editing store the selected id of the question to be edited
var editID = "";
// variable to indicate if questionnaire has been modified
var questionnaireEdited = false;
// only initializes the form management page once
var initialLoadCompleted = false;

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

//removes double quotes from the text and replaces with single quotes
function filterText(textToFilter) {
    var res = textToFilter.replace(/"/g, "'");
    return res;
}

// Show Modal
function showAddQuestionnaireModal() {
    $('#addQuestionnaire').modal('show'); 
    $('.modal-backdrop').appendTo('#formManagement');
    //$('body').removeClass("modal-open")
    //$('body').css("padding-right", "");
    //$('#addQuestionnaire').css('position', 'absolute');
    //$('#addQuestionnaire').css('width', 'inherit');
    //$('#addQuestionnaire').css('height', 'inherit');
    $('#qnaireid').focus();
}

// Show Active Questionnaire Success
function showSetActiveSuccess() {
    $('#setActiveSuccess').modal('show');
}

// Hide Active Questionnaire Success
function closeActiveSuccess() {
    $('#setActiveSuccess').modal('hide');
}

// Show Add Questionnaire Success
function showAddQuestionnaireSuccess() {
    $('#addQuestionnaireSuccess').modal('show');
}

// Hide Add Questionnaire Success
function closeAddQuestionnaireSuccess() {
    $('#addQuestionnaireSuccess').modal('hide');
    $('#qnaireid').val("");
}

// Hide Add Questionnaire Modal
function hideAddQuestionnaireModal() {
    $('#addQuestionnaire').modal('hide');
    $('#qnaireid').val("");
    hideFormManagementTags();
}

// Show Update Questionnaire Success Modal
function showUpdateSuccess() {
    $('#updateQuestionnaireSuccess').modal('show');
}

// Hide Update Questionnaire Success Modal
function closeUpdateSuccess() {
    $('#updateQuestionnaireSuccess').modal('hide');
    hideFormManagementTags();
}

//loads the page only once
function loadFormManagementOnce() {
    if (!initialLoadCompleted) {
        formManagementInit();
        initialLoadCompleted = true;
    } 
}

// Get questionaireList and Question list
function formManagementInit() {
    //if (!initialLoadCompleted) {
    hideFormManagementTags();
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
                    initialiseData(resultOfGeneration);
                    //initialLoadCompleted = true;
                } else {
                    alert(resultOfGeneration.Result);
                }
            },
            error: function (err) {
                alert(err.Msg);
            },
        });
    //}
}

// Inserts the data into the appropriate fields <Populate Dropdown List>
function initialiseData(data) {
    var qNaire = data.Qnaires;
    var qnList = data.Qns;
    fillQuestinaireList(qNaire);
    $("#allQuestions").html("");//clear questions
    fillList(qnList,$("#allQuestions"),true);
    //load the selected questionaire questions
        displayQuestionnaireQuestions();
}

//creates options and appends to the field
function fillQuestinaireList(dataForQList) {
    //clear existing options
    $('#qnaires').html("");
    for (var i = 0; i < dataForQList.length; i++) {
        var optin = document.createElement("option");
      
        $(optin).attr("style", "background:white");
        $(optin).attr("name", dataForQList[i].ListName);
        if (dataForQList[i].Active.toString() == "1") {
            $(optin).html(dataForQList[i].ListName + " (Active)");
            $(optin).attr("value", "1");
            //$(optin).attr("style", "color:green;background:#dff0d8");
            $(optin).attr("selected", "");
        } else {
            $(optin).html(dataForQList[i].ListName);
        }
        $('#qnaires').append(optin);
    }
    setSelectBackground();
}

//set the background color of the select
function setSelectBackground() {
    var num = $('.qnaire').find(":selected").attr("value");
    if (num == "1") {
        $('.qnaire').css('background', '#dff0d8');
    } else {
        $('.qnaire').css('background', 'white');
    }
}

//creates lists and appends to qn list
function fillList(dataForQnList,target,editButton) {
    //clear existing list objects
   //for qns   --->   qId,question,qnType,values
    for (var i = 0; i < dataForQnList.length; i++) {
        var listElement = document.createElement("LI");
        $(listElement).attr("class", "list-group-item");
        $(listElement).attr("data-color", "info");
        if (editButton) {
            $(listElement).attr("style", "text-align: left;position:unset !important;");
        } else {
            $(listElement).attr("style", "text-align: left;");
        }
        
         
        $(listElement).attr("id", dataForQnList[i].qId);
        $(listElement).attr("value", dataForQnList[i].question);
        $(listElement).html(dataForQnList[i].question);
      

        var inputType = document.createElement("input");
        $(inputType).attr("value", dataForQnList[i].qnType);
        $(inputType).attr("class", "qType");
        $(inputType).attr("type", "hidden");
        $(listElement).append(inputType);

        var inputValues = document.createElement("input");
        $(inputValues).attr("value", dataForQnList[i].values);
        $(inputValues).attr("class", "qValues");
        $(inputValues).attr("type", "hidden");
        $(listElement).append(inputValues);
        if (editButton) {
            var editButton = document.createElement("button");
            $(editButton).click(function () {
                //prevent default list action which is highlighting
                notEditing = false;
                    editQuestionShow($(this));
                   
            });
            $(editButton).attr("class", "btn btn-success");
            $(editButton).html("Edit");
            $(listElement).append(editButton);
        }
       

        $(target).append(listElement);

    }
    
    $(target).find('.list-group-item').each(function () {

        // Settings
        var $widget = $(this),
            $checkbox = $('<input type="checkbox" class="hidden" />'),
            color = ($widget.data('color') ? $widget.data('color') : "primary"),
            style = ($widget.data('style') == "button" ? "btn-" : "list-group-item-"),
            settings = {
                on: {
                    icon: 'glyphicon glyphicon-check'
                },
                off: {
                    icon: 'glyphicon glyphicon-unchecked'
                }
            };

        $widget.css('cursor', 'pointer')
        $widget.append($checkbox);

      


        // Actions
        function updateDisplay(obj) {
            var isChecked = $(obj).find(".hidden").is(':checked');

            // Set the button's state
            $(obj).data('state', (isChecked) ? "on" : "off");

            // Set the button's icon
            $(obj).find('.state-icon')
                .removeClass()
                .addClass('state-icon ' + settings[$(obj).data('state')].icon);

            // Update the button's color
            if (isChecked) {
                $(obj).addClass(style + color + ' active');
                $(obj).removeClass(' inactive');
            } else {
                $(obj).removeClass(style + color + ' active');
                $(obj).addClass(' inactive');
            }
        }

        // Initialization
        function init() {

            if ($widget.data('checked') == true) {
                $checkbox.prop('checked', !$checkbox.is(':checked'));
            }

            updateDisplay($widget);

            // Inject the icon if applicable
            if ($widget.find('.state-icon').length == 0) {
                $widget.prepend('<span class="state-icon ' + settings[$widget.data('state')].icon + '"></span>');
            }


            // Event Handlers

            $widget.find('span').on('click', function () {
                if (notEditing) {
                    var checkBox = $(this).parent().find(".hidden");
                    $(checkBox).prop('checked', !$(checkBox).is(':checked'));
                    $(checkBox).triggerHandler('change');
                    updateDisplay($(this).parent());
                } else {
                    notEditing = true;
                }
            });
            $checkbox.on('change', function () {
                updateDisplay($(this).parent());
            });
        }
        init();
    });
}

//hide the questions in all question list that already exists in the questionaire list of questions
function hideQuestionsAppearingInQuestionaire() {
    $("#allQuestions li").each(function (idx, li) {
        var idToHide = $(li).attr("id");
        var toHide = $(".qnQns").find("#" + idToHide);
        var test = jQuery.type(toHide);
        if ($(toHide).prop("nodeName") == "LI") {
            $(li).toggle(false);
        } else {
            $(li).toggle(true);
        }
    });
}

function displayQuestionnaireQuestions() {
    //update dropdownlist background
    setSelectBackground();
    var idl = $('.qnaire').find(":selected").attr("name");
    //create call and pull the questions out
    var headersToProcess = {
        requestType: "getQuestionaireFromList",
        ListID: idl
    };
    $.ajax({
        url: '../Staff/QuestionaireManagement/questionaireManagement.ashx',
        method: 'post',
        data: headersToProcess,


        success: function (returner) {
            resultOfGeneration = JSON.parse(returner);
            var res = resultOfGeneration.Result;
            if (res.toString() == "Success") {
                if (resultOfGeneration.qnQns[0].question != "0") {
                    $(".qnQns").html("");
                    fillList(resultOfGeneration.qnQns, $(".qnQns"), false);
                } else {
                    $(".qnQns").html("");
                }
                hideQuestionsAppearingInQuestionaire();
            } else {
                alert(resultOfGeneration.Result);
            }
        },
        error: function (err) {
            alert(err.Msg);
        },
    });
}

//Filter the list of available questions
function filterCurrentList(elment) {
    var value = $(elment).val();
    if (value == '' || value == ' ') {
        $('#allQuestions > li').show();
        hideQuestionsAppearingInQuestionaire();
    } else {
        $('#allQuestions > li:not(:containsi(' + value + '))').hide();
        $('#allQuestions > li:containsi(' + value + ')').show();
    }
   
}

//select all given a target object
function selectAll(target) {
    if (target == 'qns') {
        //get the list and get all the options
        $("#allQuestions li.inactive span").each(function (idx, li) {
           $(li).triggerHandler('click');
        });
        
    } else if (target == 'qnaire') {
        $(".qnQns li.inactive span").each(function (idx, li) {
            $(li).triggerHandler('click');
        });
    }
}
//deselect all from a target list given a keyword
function deSelectAll(target) {
    if (target == 'qns') {
        //get the list and get all the options
        $("#allQuestions li.active span").each(function (idx, li) {
            $(li).triggerHandler('click');
        });

    } else if (target == 'qnaire') {
        $("#sortable li.active span").each(function (idx, li) {
            $(li).triggerHandler('click');
        });
    }
}

// Add new questionnaire
function newQuestionnaire() {
    var resultOfGeneration = "";
    var qname = $("#qnaireid").val();
    if (qname !== "") {
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
                    if (resultOfGeneration.Msg === "1") {
                        selectNewQuestionnaire(qname);
                        hideAddQuestionnaireModal();
                        showAddQuestionnaireSuccess();
                        $("#emptyQuestionnaireWarning").css("display", "none");
                        $("#questionnaireWarning").css("display", "none");
                    } else {
                        $("#questionnaireWarning").css("display", "block");
                        $("#emptyQuestionnaireWarning").css("display", "none");
                    }    
                } else {
                    alert("SQL Error: Please contact the administrator");
                }
            },
            error: function (err) {
                alert(err.Msg);
            },
        });
    } else {
        $("#emptyQuestionnaireWarning").css("display", "block");
        $("#questionnaireWarning").css("display", "none");
    }
}

// Selects newly created questionnaire after adding
function selectNewQuestionnaire(qName) {
    var optin = document.createElement("option");
    $(optin).attr("name", qName);
    $(optin).html(qName + " (New)");
    $(optin).attr("selected", "");
    $('#qnaires').append(optin);
    $('#sortable').html("");
    $('.qnaire').css('background', '#aaddff');
}

//Clear questionaire fields
function clearQnEditorFields() {
    $('#qnEditor .qnVal').each(function (idx, obj) {
        $(obj).val("");
         
    });
    var update = false;
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
            // Success Message
        },
        error: function (err) {
            alert(err.Msg);
        },
    });
}

//Variable to store condition on create or update question
var update = true;

//toggle qn editor
function toggleQnEditor() {
    //var state = $("#qnEditor").hasClass('in')  ;
    var state = $("#qnEditor").hasClass('in');

    if (!state || update == true) {
        $("#editQuestionTitle").html("New Question Details");
        isCreateQn = true;
        $("#searchQ").prop('readonly', true);
        $('#qnEditor').collapse("show");
        clearQnEditorFields();
        toggleListGreyOut(true);
        update = false;
    } else {
        $('#qnEditor').collapse("hide");
        clearQnEditorFields();
        $("#searchQ").prop('readonly', false);
        toggleListGreyOut(false)
    }
}

//disable entire list
function toggleListGreyOut(display) {
    $("#cover").toggle(display);
}

//When the edit question button is pressed
function editQuestionShow(me) {
    isCreateQn = false;
    toggleListGreyOut(true);
    var qn = $(me).parent().text();
    var qn = qn.substring(0, qn.length - 4);
    var qnType = $(me).parent().find(".qType").val();
    var qnValues = $(me).parent().find(".qValues").val();
    editID = $(me).parent().attr("id");
    $("#detailsQn").val(qn);
    $("#detailsQnType").val(qnType);
    $("#detailsQnValues").val(qnValues);
    $("#editQuestionTitle").html("Edit Question Details");
    update = true;
    $('#qnEditor').collapse("show");

}

//close question editor
function closeEditor() {
    clearQnEditorFields();
    toggleListGreyOut(false);
    update = false;
    $('#qnEditor').collapse("hide");
    $("#searchQ").prop('readonly', false);
    hideFormManagementTags();
}

// Update or create a Question depending on condition
function updateOrCreate() {
    var question = filterText($("#detailsQn").val());
    var questionType = $("#detailsQnType").val();
    var questionVal = $("#detailsQnValues").val();
    if (question !== "" & questionType !== "") {
        if (isCreateQn) {
            var headersToProcess = {
                requestType: "addQuestion",
                question: question,
                questionType: questionType,
                questionValues: questionVal
            };
        }
        else {
            var valid = /^[,]*$/.test(questionVal.toString());
            if (questionType !== "text" & (questionVal == "" || /^[,]*$/.test(questionVal.toString()))) {
                $("#questionValWarning").css("display", "block");
            } else {
                var headersToProcess = {
                    requestType: "updateQuestion",
                    qnId: editID,
                    question: question,
                    questionType: questionType,
                    questionValues: questionVal
                };
            }
            var resultOfGeneration = "";

        }


        $.ajax({
            url: '../Staff/QuestionaireManagement/questionaireManagement.ashx',
            method: 'post',
            data: headersToProcess,


            success: function (returner) {
                resultOfGeneration = JSON.parse(returner);
                var res = resultOfGeneration.Result;
                if (res == "Success") {
                    $("#emptyQuestionWarning").css("display", "none");
                    $("#questionValWarning").css("display", "none");
                    formManagementInit();
                    closeEditor();

                } else {
                    alert("An error has occured. Please Contact the administrator");
                }
            },
            error: function (err) {
                alert(err.Msg);
            },
        });
    } else {
        $("#emptyQuestionWarning").css("display", "block");
    }
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
    // For all the li with active classes in the div, copy the html & append to the questionnaire list
    var ids = [];
    var questions = [];
    var count = 1;
    $.each($("#allQuestions li.active "), function (idx, li) {
        $(this).toggle("hide");
        $(li).find("span").triggerHandler("click");
        var listobj = $(li).clone(true);
        var listobjBtn = $(listobj).find(".btn");
        $(listobjBtn).remove();
        ids.push(listobj);
    });
    // Write HTML <li> & append to sortable ul
    for (i = 0; i < ids.length; i++) {
        var item = ids[i];
        $('#sortable').append(item);
    }
    questionnaireEdited = true;
}

// Update Questionnaire
function updateQuestionnaire() {
    var resultOfGeneration = "";
    var qnQns = "";
    var qnaireId = $('#qnaires option:selected').attr('name');
    var count = 1;
    $.each($('#sortable li'), function (index, value) {
        if (count > 1) {
            qnQns += ',';
        }
        qnQns += $(value).attr('id');
        count++;
    });
    var headersToProcess = {
        qnQns: qnQns, qnaireId: qnaireId, requestType: "update"
    };
    $.ajax({
        url: '../Staff/QuestionaireManagement/questionaireManagement.ashx',
        method: 'post',
        data: headersToProcess,


        success: function (returner) {
            resultOfGeneration = JSON.parse(returner);
            var res = resultOfGeneration.Msg;
            showUpdateSuccess();
            questionnaireEdited = false;
        },
        error: function (err) {
            alert(err.Msg);
        },
    });

}


// Get the id's of all the check <li>s in the quetionnaire & delete them from the list.
$('#delQuestionsFromQuestionnaire').click(function () {
    $.each($("#sortable li.active"), function (idx, li) {
        $(li).remove();
    });
    questionnaireEdited = true;
});

// Set selected questionnaire to active
function setActiveQuestionnaire() {
    var qnaireId = $("#qnaires").val().toString();
    qnaireId = qnaireId.replace(" (New)", "");
    if (qnaireId == "1") {
        alert("This questionnaire is already active!");
        return;
    }
    var headersToProcess = {
        qnaireId: qnaireId, requestType: "active"
    };
    $.ajax({
        url: '../Staff/QuestionaireManagement/questionaireManagement.ashx',
        method: 'post',
        data: headersToProcess,


        success: function (returner) {
            var resultOfGeneration = JSON.parse(returner);
            //load the selected questionaire questions
            selectActiveQuestionnaire();
            
        },
        error: function (err) {
            alert(err.Msg);
        },
    });
}

// Select the newly activated questionnaire
function selectActiveQuestionnaire() {
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
                var dataForQList = resultOfGeneration.Qnaires;
                $('#qnaires').html("");
                for (var i = 0; i < dataForQList.length; i++) {
                    var optin = document.createElement("option");

                    $(optin).attr("style", "background:white");
                    $(optin).attr("name", dataForQList[i].ListName);
                    if (dataForQList[i].Active.toString() == "1") {
                        $(optin).html(dataForQList[i].ListName + " (Active)");
                        $(optin).attr("value", "1");
                        $(optin).attr("style", "color:green;background:#dff0d8");
                        $(optin).attr("selected", "");
                    } else {
                        $(optin).html(dataForQList[i].ListName);
                    }
                    $('#qnaires').append(optin);
                }
                setSelectBackground();
                showSetActiveSuccess();
            } else {
                alert(resultOfGeneration.Result);
            }
        },
        error: function (err) {
            alert(err.Msg);
        },
    });
}

// Hides all Form Management Warnings
function hideFormManagementTags() {
    $("#emptyQuestionnaireWarning").css("display", "none");
    $("#questionnaireWarning").css("display", "none");
    $("#emptyQuestionWarning").css("display", "none");
    $("#questionWarning").css("display", "none");
    $("#questionValWarning").css("display", "none");
}

function checkAnsType() {
    var type = $("#detailsQnType").val();
    if (type == "text" || type == "") {
        $("#detailsQnValues").prop('readonly', true);
    } else {
        $("#detailsQnValues").prop('readonly', false);
    }
}