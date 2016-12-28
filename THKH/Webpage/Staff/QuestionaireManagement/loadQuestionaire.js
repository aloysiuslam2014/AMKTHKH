//create a case insensitive jquery contains method
$.extend($.expr[':'], {
    'containsi': function (elem, i, match, array) {
        return (elem.textContent || elem.innerText || '').toLowerCase()
            .indexOf((match[3] || "").toLowerCase()) >= 0;
    }
});

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
                initialiseData(resultOfGeneration)
            } else {
                alert(resultOfGeneration.Result);
            }
        },
        error: function (err) {
            alert(err.Msg);
        },
    });

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
            $(optin).attr("style", "color:green;background:#dff0d8");
            $(optin).attr("selected", "");
        } else {
            $(optin).html(dataForQList[i].ListName);
        }
        $('#qnaires').append(optin);
    }
    //set the background color of the select
    setSelectBackground();
    
}

function setSelectBackground() {
    var num = $('.qnaire').find(":selected").attr("value");
    if (num == "1") {
        $('.qnaire').css('background', '#dff0d8');
    } else {
        $('.qnaire').css('background', 'white');
    }
}

//if the user clicked the qn edit button or not. To prevent li from activating if the edit button was pressed
var notEditing = true;
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
                $(".qnQns").html("");
                fillList(resultOfGeneration.qnQns, $(".qnQns"), false);
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

function filterCurrentList(elment) {

    var value = $(elment).val();
    if (elment == '' || elment == ' ') {
        $('#allQuestions > li').show();
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

        $('#qnEditor').collapse("show");
        clearQnEditorFields();
        toggleListGreyOut(true);
        update = false;
    } else {
        $('#qnEditor').collapse("hide");
        clearQnEditorFields();
        toggleListGreyOut(false)
    }
    
}

//disable entire list
function toggleListGreyOut(display) {
    $("#cover").toggle(display);
}

//When the edit question button is pressed
function editQuestionShow(me) {
    toggleListGreyOut(true);
    var qn = $(me).parent().text();
    var qnType = $(me).parent().find(".qType").val();
    var qnValues = $(me).parent().find(".qValues").val();
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
}
// Update or create a Question
function updateOrCreate() {
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
            alert("Questionnaire Updated!");
        },
        error: function (err) {
            alert(err.Msg);
        },
    });

}


// Get the id's of all the check <li>s in the quetionnaire & delete them from the list.
$('#delQuestionsFromQuestionnaire').click(function () {
    $.each($("#sortable li.active"), function (idx, li) {
        // remove li
        $(li).remove();
    });
});

function setActiveQuestionnaire() {
    var qnaireId = $("#qnaires").val();
    var headersToProcess = {
        qnaireId: qnaireId, requestType: "active"
    };
    $.ajax({
        url: '../Staff/QuestionaireManagement/questionaireManagement.ashx',
        method: 'post',
        data: headersToProcess,


        success: function (returner) {
            var resultOfGeneration = JSON.parse(returner);
            formManagementInit();
            alert(qnaireId + " set as active!");
        },
        error: function (err) {
            alert(err.Msg);
        },
    });
}