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
    fillList(qnList,$("#allQuestions"));
    //load the selected questionaire questions
        displayQuestionnaireQuestions();
}
//creates options and appends to the field
function fillQuestinaireList(dataForQList) {
    //clear existing options
    $('#qnaires').html("");
    for (var i = 0; i < dataForQList.length; i++) {
        var optin = document.createElement("option");
        $(optin).html(dataForQList[i].ListName);
        $(optin).attr("style", "background:white");
        $(optin).attr("name", dataForQList[i].ListName);
        if (dataForQList[i].Active.toString() == "1") {
            $(optin).attr("value", "1");
          //  $(optin).attr("data-color", "info"); 
            $(optin).attr("style", "color:green;background:#dff0d8");
            $(optin).attr("selected", "");
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
//creates lists and appends to qn list
function fillList(dataForQnList,target) {
    //clear existing list objects
   //for qns   --->   qId,question,qnType,values
    for (var i = 0; i < dataForQnList.length; i++) {
        var listElement = document.createElement("LI");
        $(listElement).attr("class", "list-group-item");
        $(listElement).attr("data-color", "info");
        $(listElement).attr("style", "text-align: left;");
         
        $(listElement).attr("id", dataForQnList[i].qid);
        $(listElement).html(dataForQnList[i].question);
        $(target).append(listElement);
    }
    $('.list-group.checked-list-box .list-group-item').each(function () {

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

        // Event Handlers
        $widget.on('click', function () {
            $checkbox.prop('checked', !$checkbox.is(':checked'));
            $checkbox.triggerHandler('change');
            updateDisplay();
        });
        $checkbox.on('change', function () {
            updateDisplay();
        });


        // Actions
        function updateDisplay() {
            var isChecked = $checkbox.is(':checked');

            // Set the button's state
            $widget.data('state', (isChecked) ? "on" : "off");

            // Set the button's icon
            $widget.find('.state-icon')
                .removeClass()
                .addClass('state-icon ' + settings[$widget.data('state')].icon);

            // Update the button's color
            if (isChecked) {
                $widget.addClass(style + color + ' active');
                $widget.removeClass(  ' inactive');
            } else {
                $widget.removeClass(style + color + ' active');
                $widget.addClass(' inactive');
            }
        }

        // Initialization
        function init() {

            if ($widget.data('checked') == true) {
                $checkbox.prop('checked', !$checkbox.is(':checked'));
            }

            updateDisplay();

            // Inject the icon if applicable
            if ($widget.find('.state-icon').length == 0) {
                $widget.prepend('<span class="state-icon ' + settings[$widget.data('state')].icon + '"></span>');
            }
        }
        init();
    });
}

function displayQuestionnaireQuestions() {
    //update dropdownlist background
    setSelectBackground();
    //create call and pull the questions out
    var headersToProcess = {
        requestType: "getQuestionaireFromList",
        ListID: $('.qnaire').find(":selected").html()
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
                fillList(resultOfGeneration.qnQns, $(".qnQns"));
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
        $("#allQuestions li.inactive").each(function (idx, li) {
           $(li).triggerHandler('click');
        });
        
    } else if (target == 'qnaire') {
        $(".qnQns li.inactive").each(function (idx, li) {
            $(li).triggerHandler('click');
        });
    }
}
//deselect all from a target list given a keyword
function deSelectAll(target) {
    if (target == 'qns') {
        //get the list and get all the options
        $("#allQuestions li.active").each(function (idx, li) {
            $(li).triggerHandler('click');
        });

    } else if (target == 'qnaire') {
        $("#sortable li.active").each(function (idx, li) {
            $(li).triggerHandler('click');
        });
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
    // For all the li with active classes in the div, copy the html & append to the questionnaire list
}

// Update Questionnaire
function updateQuestionnaire() {
    var resultOfGeneration = "";
    var qnQns = "";
    var qnaireId = $("#qnaires").val();
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
    var arr = [];
    var str = $('li').each(function (i) {
        if ($(this).is('.active')) arr.push($(this).val($(this).attr('id')));
    });
    //$('#tl_2').remove();
    var one = 1;
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