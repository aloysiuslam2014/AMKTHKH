$(function () {
   

    $('#addTerminal').on('click', function (event) {
        $('#addTerminalModal').modal({ backdrop: 'static', keyboard: false });
        $('.modal-backdrop').appendTo('#TerminalManagement');
        $('body').removeClass("modal-open")
        $('body').css("padding-right", "");
        $('#addTerminalModal').css('position', 'absolute');
        $('#addTerminalModal').css('width', 'inherit');
        $('#addTerminalModal').css('height', 'inherit');
      
    });

    
    $('#terminalBedLink').on('change', function () {
        
        if (this.value == "Yes") {
            $("#beds").prop('disabled', false);
        } else {
            $("#beds").prop('disabled', true);
        }
    })

    $('#addTerminalModal').on('shown.bs.modal', function () {
        $('#terminalNameInput').focus();
    });

    $('#addTerminalModal').on('hidden.bs.modal', function () {
        $('#terminalNameInput').val("");
        $('#addTerminalModal #beds').val("");
    });

    $('#adminCloseTerminal').on('click', function (event) {
        $('#addTerminalModal').modal('hide');
    });

    $('#closeAllTerminal').on('click', function (event) {
        $('#promptTerminalModal').modal('hide');
        $('#addTerminalModal').modal('hide');
        $('#terminalNameInput').html("");
        loadTerminals();
    });

    $('#addNewTerminal').on('click', function (event) {
        event.preventDefault();
         
        //create looped ajax call to delete terminal
        

        var headersToProcess = {
            action: "addTerminal",
            id: terminalNameInput.value,
            bedList: beds.value,
            isInfectious: terminalInfectious.value == "Yes" ? 1 : 0
        };
            $.ajax({
                url: './TerminalCalls/TerminalCheck.ashx',
                method: 'post',
                data: headersToProcess,


                success: function (returner) {
                    //Alert to show terminal has been added
                    $('#promptTerminalModal').modal({ backdrop: false, keyboard: false });
                    if (returner.toString() == "success")
                    {
                        $('#prompText').html("Terminal Successfully Added!");
                    } else {
                        $('#prompText').html("Terminal Name Already Exist!");
                    }
                    
                },
                error: function (err) {
                    alert("error");
                },
            });
       
    });

    $('#cancelAction').on('click', function (event) {
        $('#genericTerminalModal').modal('hide');
        $("#confirmAction").toggle(true);
    });

    $('#deactivateTerminal').on('click', function (event) {
        event.preventDefault();
        if ($("#terminalList .active").length == 0) {
            noTerminalSelected();
            return;
        }
        var inavtiveTerminaltest = "";
      
        if ( $("#terminalList .active").hasClass("inactive")) {
            inavtiveTerminaltest = "<i>Inactive terminal(s) selected.</i>";
        }
    
        $('#GenericMessage').html("Are you sure you want to <B>DEACTIVATE</B> the selected terminal(s)? <br>" + inavtiveTerminaltest);
        $('#genericTerminalModal').modal({ backdrop: 'static', keyboard: false });
        $('#genericTerminalModal').modal({ backdrop: 'static', keyboard: false });
        $('.modal-backdrop').appendTo('#TerminalManagement'); 
        $('#confirmAction').on('click', function (event) {
            genericTerminalCofirmation("deactivateTerminal");
        });
      
    });
    $('#deleteTerminal').on('click', function (event) {
        event.preventDefault();
       
         
        $('#GenericMessage').html("Are you sure you want to <B>DELETE</B> the selected terminal(s)? ");
        $('.modal-backdrop').appendTo('#TerminalManagement');
        $('#confirmAction').on('click', function (event) {
            genericTerminalCofirmation("deleteTerminal");
        });
    });
    $('#deactivateAll').on('click', function (event) {
        event.preventDefault();
        
      
        $('#GenericMessage').html("Are you sure you want to <B>DEACTIVATE <font color='red'>ALL</font></B> the selected terminal(s)?");
        $('#genericTerminalModal').modal({ backdrop: 'static', keyboard: false });
        $('.modal-backdrop').appendTo('#TerminalManagement');
        $('#confirmAction').on('click', function (event) {
            genericTerminalCofirmation("deactivateAllTerminal");
        });

    });
    $('#deleteAll').on('click', function (event) {
        event.preventDefault();
       ;
        $('#GenericMessage').html("Are you sure you want to  <B>DELETE <font color='red'>ALL</font></B> the selected terminal(s)?");
        $('#genericTerminalModal').modal({ backdrop: 'static', keyboard: false });
        $('.modal-backdrop').appendTo('#TerminalManagement');
        $('#confirmAction').on('click', function (event) {
            genericTerminalCofirmation("deleteAllTerminal")
        });
         
      
    });
});

function noTerminalSelected() {
    $('#GenericMessage').html("No terminals have been selected. Please select a terminal and try again.");
    $('#genericTerminalModal').modal({ backdrop: 'static', keyboard: false });
    $('.modal-backdrop').appendTo('#TerminalManagement');
    $("#confirmAction").toggle(false);
}

function selectAllTerminals() {
   
        //get the list and get all the options
    $("#terminalList li:not(.active)").each(function (idx, li) {
            $(li).triggerHandler('click');
        });

   
}
 
function deselectAllTerminals() {
        
    //get the list and get all the options
    $("#terminalList li.active").each(function (idx, li) {
        $(li).triggerHandler('click');
    });


}

function genericTerminalCofirmation(type){
    //All buttons will have a warning before proceeding on...
  
    
    var selectedItems = getSelectedTerminals();
    if (type == "deactivateTerminal") {
       
        //create looped ajax call to deactivate Terminal
        for (var i = 0; i < selectedItems.length ; i++) {

            var headersToProcess = { action: "deactivate", id: selectedItems[i] };
            $.ajax({
                url: './TerminalCalls/TerminalCheck.ashx',
                method: 'post',
                data: headersToProcess,


                success: function (returner) {
                    if (i == selectedItems.length) {
                        loadTerminals();

                    }
                    $(selectedItems[i]).addClass("inactive");
                },
                error: function (err) {
                    alert("error");
                },
            });
        }
    }
    else if (type === "deleteTerminal") {
        //create looped ajax call to delete terminal
        for (var i = 0; i < selectedItems.length ; i++) {

            var headersToProcess = { action: "deleteTerminals", id: selectedItems[i] };
            $.ajax({
                url: './TerminalCalls/TerminalCheck.ashx',
                method: 'post',
                data: headersToProcess,


                success: function (returner) {
                    if (i == selectedItems.length) {
                        loadTerminals();
                    }

                },
                error: function (err) {
                    alert("error");
                },
            });
        }
    }
    else if (type == "deactivateAllTerminal") {
        //deactivate all terminal
        var headersToProcess = { action: "deactivateAllTerminals", id: selectedItems[i] };
        $.ajax({
            url: './TerminalCalls/TerminalCheck.ashx',
            method: 'post',
            data: headersToProcess,


            success: function (returner) {

                loadTerminals();
            },
            error: function (err) {
                alert("error");
            },
        });
    }
    else if (type == "deleteAllTerminal") {
        //delete all terminal
        var headersToProcess = { action: "deleteAllTerminals", id: selectedItems[i] };
        $.ajax({
            url: './TerminalCalls/TerminalCheck.ashx',
            method: 'post',
            data: headersToProcess,


            success: function (returner) {

                loadTerminals()
            },
            error: function (err) {
                alert("error");
            },
        });

    }
  
    $('#genericTerminalModal').modal('hide');
    $('#confirmAction').prop('onclick', null);
}

function loadTerminals() {
    var headersToProcess = { action: "getAllTerminals", id: "" };
    //get the terminals
    $.ajax({
        url: './TerminalCalls/TerminalCheck.ashx',
        method: 'post',
        data: headersToProcess,


        success: function (returner) {
            //generate elements and append to the ul
            generateTerminalListAndInit(returner);
            
        },
        error: function (err) {
            alert("error");
        },
    });

   
}

function generateTerminalListAndInit(terminalData) {
    $("#terminalList").html('');
    var terminalsReceived = terminalData.split("|");
    for (i = 0; i < terminalsReceived.length - 1; i++) {
        var datas = terminalsReceived[i].split(",");
        var terminalName = datas[1];
        var terminalID = datas[0];
        var listElement = document.createElement("LI");
        $(listElement).attr("class", "list-group-item");
        $(listElement).attr("data-color", "info");
        if (datas[2].toString() == "1") {
           
            $(listElement).attr("style", "text-align: left;color:#3c763d");
            
        } else {
           
            $(listElement).attr("style", "text-align: left;color: #a94442;");
            $(listElement).addClass("inactive");
        }
       
        $(listElement).attr("id", terminalID);
        $(listElement).html(terminalName);
        $("#terminalList").append(listElement);
    }
    $('#TerminalManagement .list-group.checked-list-box .list-group-item').each(function () {

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
            } else {
                $widget.removeClass(style + color + ' active');
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

function getSelectedTerminals() {
    
       
    var checkedItems = [];
    $("#terminalList li.active").each(function (idx, li) {
        checkedItems.push($(li).attr('id'));
            
        });
        //$('#display-json').html(JSON.stringify(checkedItems, null, '\t'));
        return checkedItems;
}