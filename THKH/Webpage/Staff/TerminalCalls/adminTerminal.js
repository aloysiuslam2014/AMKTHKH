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

    $('#addTerminalModal').on('shown.bs.modal', function () {
        $('#terminalNameInput').focus();
    })

    $('#adminCloseTerminal').on('click', function (event) {
        $('#addTerminalModal').modal('hide');
    });

    $('#addNewTerminal').on('click', function (event) {
        event.preventDefault();
         
        //create looped ajax call to delete terminal
        for (var i = 0; i < selectedItems.length ; i++) {

            var headersToProcess = { action: "addTerminal", id: terminalNameInput.value };
            $.ajax({
                url: './TerminalCalls/TerminalCheck.ashx',
                method: 'post',
                data: headersToProcess,


                success: function (returner) {
                   //Alert to show terminal has been added
                },
                error: function (err) {
                    alert("error");
                },
            });
        }
    });
     
    $('#deactivateTerminal').on('click', function (event) {
        event.preventDefault();
        var selectedItems = getSelectedTerminals();
        //create looped ajax call to deactivate Terminal
        for(var i = 0;i < selectedItems.length ; i++){
          
            var headersToProcess = { action: "deactivate", id: selectedItems[i] };
            $.ajax({
                url: './TerminalCalls/TerminalCheck.ashx',
                method: 'post',
                data: headersToProcess,


                success: function (returner) {
                    if (i + 1 == selectedItems.length)
                        loadTerminals();
                },
                error: function (err) {
                    alert("error");
                },
            });
        }
    });

    $('#deleteTerminal').on('click', function (event) {
        event.preventDefault();
        var selectedItems = getSelectedTerminals();
        //create looped ajax call to delete terminal
        for (var i = 0; i < selectedItems.length ; i++) {

            var headersToProcess = { action: "deleteTerminals", id: selectedItems[i] };
            $.ajax({
                url: './TerminalCalls/TerminalCheck.ashx',
                method: 'post',
                data: headersToProcess,


                success: function (returner) {
                    if (i + 1 == selectedItems.length)
                        loadTerminals();
                },
                error: function (err) {
                    alert("error");
                },
            });
        }
    });
    $('#deactivateAll').on('click', function (event) {
        event.preventDefault();
        var selectedItems = getSelectedTerminals();
        //deactivate all terminal
        var headersToProcess = { action: "deactivateAllTerminals", id: selectedItems[i] };
        $.ajax({
            url: './TerminalCalls/TerminalCheck.ashx',
            method: 'post',
            data: headersToProcess,


            success: function (returner) {
                if (i + 1 == selectedItems.length)
                    loadTerminals();
            },
            error: function (err) {
                alert("error");
            },
        });

    });
});
 

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
        
        if (datas[2].toString() == "1") {
            $(listElement).attr("data-color", "success");
            $(listElement).attr("style", "text-align: left;color:'#3c763d'");
        } else {
            $(listElement).attr("data-color", "info");
            $(listElement).attr("style", "text-align: left");
        }
       
        $(listElement).attr("id", terminalID);
        $(listElement).html(terminalName);
        $("#terminalList").append(listElement);
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