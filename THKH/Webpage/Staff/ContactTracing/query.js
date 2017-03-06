var toTracing = './ContactTracing/tracing.ashx';
var selfRegNoDataError = "Selected period returns no data. Please try another date";
var serverAjaxFailureError = "There was a problem retrieving valid terminals.";


var visitors, visitDetails;
var uq_bednos = document.getElementById("uq_bednos");
var uq_loc = document.getElementById("uq_loc");

function enableToggle(current, other) {

    other.disabled = current.value.replace(/\s+/, '').length > 0;

}

function unifiedTrace() {
    var resultTable = document.getElementById("uq_resultstable_body");
    while (resultTable.firstChild) {
        resultTable.removeChild(resultTable.childNodes[0]);
    }
    var uq_dateStart = $("#uq_startdatetime").val();
    var uq_dateEnd = $("#uq_enddatetime").val();

    var _dateStart = new Date(uq_dateStart);
    var _dateEnd = new Date(uq_dateEnd);

    if (_dateStart > _dateEnd) {
        alert("End date of query period must be before start date!");
        return;
    }
    var uq_querybeds = $("#uq_bednos").val();
    var uq_loc = $("#uq_loc").val();
    uq_params = "";
    if (uq_loc == "") {
        uq_params = "bybed~" + uq_dateStart + '~' + uq_dateEnd + '~' + uq_querybeds;
    }
    if (uq_querybeds == "") {
        uq_params = "byloc~" + uq_dateStart + '~' + uq_dateEnd + '~' + uq_loc;
    }

    var headersToProcess = { action: "unifiedTrace", queries: uq_params };
    $.ajax({
        url: toTracing,
        method: 'post',
        data: headersToProcess,

        success: function (returner) {
            try {
                var uqResult = JSON.parse(returner);
                var arrLen = uqResult.Msg.length;

                var result_table = $('#uq_resultstable').dataTable();
                
                result_table.fnClearTable();

                for (i = 0; i < arrLen; i++) {
                    var uqResultJSON = uqResult.Msg[i];
                    result_table.fnAddData(uqResultJSON);
                }
            } catch (err) {
                alert("Selected period returns no data. Please try again. " + err);
            }
           
        },
        error: function (err) {
            alert("There was a problem executing the trace, please contact the admin.");
        },
    });
}

function writeUQResultsTable(uqResultJSON) {

    $("#generateCSV").removeClass('disabled');//Enable csv download button
            var vparams = ["location", "bedno", "checkin_time", "exit_time", "fullName", "nric", "mobileTel", "nationality", "reg", "scan"];

            //visitor
            var row = document.createElement("tr");
            $(row).attr("class", "info");

            for (rowindex = 0; rowindex < vparams.length; ++rowindex) {
                var cell = document.createElement("td");
                var item = uqResultJSON[vparams[rowindex]];
                $(cell).html(uqResultJSON[vparams[rowindex]]);
                $(row).append(cell);
            }

            $("#uq_resultstable_body").append(row);
}

function traceByReg() {
    $("traceByRegResultTable").remove();
    var ri_dateStart = $("#ri_qstartdatetime").val();
    var ri_dateEnd = $("#ri_qenddatetime").val();
    var ri_querybeds = $("#ri_querybeds").val();

    byRegQueryParams = ri_dateStart + '~' + ri_dateEnd + '~' + ri_querybeds;

    var headersToProcess = { action: "traceByReg", queries: byRegQueryParams };
    $.ajax({
        url: toTracing,
        method: 'post',
        data: headersToProcess,

        success: function (returner) {
            var byRegResults = JSON.parse(returner);
            var byRegResultsJson = byRegResults.Msg[0];
            if (byRegResultsJson.visitors != "") {
                var visitorsk = byRegResultsJson.visitors;
                var visitDetailsk = byRegResultsJson.visitorDetails;
                writeByRegResultsTable(visitorsk, visitDetailsk);
            } else {
                alert(selfRegNoDataError);
            }
           
        },
        error: function (err) {
            alert(serverAjaxFailureError);
        },
    });
}

function writeByRegResultsTable(visitorsx, visitorDetails) {
     
    $("#ri_resultTable_body").html('');//clear existing elements
    $("#generateCSV").removeClass('disabled');//Enable csv download button
    visitors = JSON.parse(visitorsx);
    visitDetails = JSON.parse(visitorDetails);
    visitors = visitors.Visitors;
    visitDetails = visitDetails.Visitor_Details;
    for (index = 0; index < visitors.length; ++index) {
        var v = visitors[index];
        var vparams = ["nric", "fullName", "gender", "nationality", "dateOfBirth", "race", "mobileTel", "homeTel", "altTel", "email", "homeAddress", "postalCode", "time_stamp", "confirm", "amend"];
        //visitor
        var row = document.createElement("tr");

        for (rowindex = 0; rowindex < vparams.length; ++rowindex) {
            var cell = document.createElement("td");
            $(cell).html(v[vparams[rowindex]]);
            $(row).append(cell);
        }

        $("#ri_resultTable_body").append(row);
    }
}

function generateCSV() {
    //convert the data a csv array
    var csvGenerate = [];
    var csvHeader ;
    var visitItem;
    for (var i = 0 ; i < visitDetails.length; i++) {
        var visitDetailToCSV = "";
        visitItem = visitDetails[i];
        var visitItemElementKeys = Object.keys(visitItem);
        for (var x = 0; x < visitItemElementKeys.length; x++) {
            visitDetailToCSV += visitItem[visitItemElementKeys[x]];
            if (x + 1 < visitItemElementKeys.length) {
                visitDetailToCSV+=",";
            }
        }
        var visitProfileCSV = "";
        for (var z = 0; z < visitors.length; z++) {
            var item = visitors[z];
            if (item.nric == visitItem.visitorNric) {
                visitItem = item;
                csvHeader = Object.keys(visitItem);
                csvHeader = csvHeader.concat(visitItemElementKeys);
                visitItemElementKeys = Object.keys(visitItem);
                for (var x = 0; x < visitItemElementKeys.length; x++) {
                    visitProfileCSV += visitItem[visitItemElementKeys[x]];
                    if (x + 1 < visitItemElementKeys.length) {
                        visitProfileCSV += ",";
                    }
                }
            }
        }
        csvGenerate.push(csvHeader);
        csvGenerate.push(visitProfileCSV + "," + visitDetailToCSV);
    }
    var csvContent = "data:text/csv;charset=utf-8,";
    csvGenerate.forEach(function (infoArray, index) {
        csvContent += index < csvGenerate.length ? infoArray + "\n" : infoArray;

    });

    var encodedUri = encodeURI(csvContent);
    var link = document.createElement("a");
    link.setAttribute("href", encodedUri);
    link.setAttribute("download", "traceResultsForBed.csv");
    document.body.appendChild(link); // Required for FF
    link.click(); // This will download the data file named "my_data.csv".
}

function getValidTerminals() {
    $(validTerminalList).html("");
    var dateStart = $("#qstartdatetime").val();// value in real time // DOM-live value , Static-web value
    var dateEnd = $("#qenddatetime").val();
    queryDates = dateStart + '~' + dateEnd
    var headersToProcess = { action: "getValidTerminals", queries: queryDates };
    $.ajax({
        url: toTracing,
        method: 'post',
        data: headersToProcess,

        success: function (returner) {
            var terminalQuery = JSON.parse(returner);
            var terminalarr = [];
            terminalarr = terminalQuery.Msg;
            for (index = 0; index < terminalarr.length; ++index) {
                writeTerminalResult(terminalarr[index], dateStart, dateEnd);
            }

            $('#ContactTracing .list-group.checked-list-box .list-group-item').each(function () {

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
        },
        error: function (err) {
            alert(serverAjaxFailureError);
        },
    });
}

function writeTerminalResult(terminal, startdate, enddate) {
    var queryStartDate = Date.parse(startdate);
    var queryEndDate = Date.parse(enddate);
    var tname = terminal.tname;
    var tstartdate = terminal.startd;
    var tenddate = terminal.endd;
    var qstartdate = tstartdate;
    var qenddate = tenddate;
    if (Date.parse(tstartdate) > queryStartDate) {
        qstartdate = queryStartDate;
    }
    if (tenddate === "" || Date.parse(tenddate) < queryEndDate) {
        qenddate = queryEndDate;
    }
    var listObj = document.createElement("LI");
    $(listObj).prop("style","cursor: pointer;display: inline-flex;width: 100%;")
    var listDiv = document.createElement("DIV");
    $(listDiv).prop("style", "width: 100%;display: inherit;height: 100%;");
    $(listObj).prop("class", "list-group-item row")
    //tName
    var t_div = document.createElement("div");
    $(t_div).prop("class", "col-sm-4");
    var t_label = document.createElement("label");
    $(t_label).prop("class", "terminalLabel ");
    $(t_label).html(tname);
    $(t_div).html(t_label);

    //qstartdate
    var startd_div = document.createElement("div");
    $(startd_div).prop("class", "col-sm-4");
    var startd_label = document.createElement("label");
    $(startd_label).prop("class", "startdLabel");
    $(startd_label).html(qstartdate);
    $(startd_div).html(startd_label);

    //qenddate
    var endd_div = document.createElement("div");
    $(endd_div).prop("class", "col-sm-4");
    var endd_label = document.createElement("label");
    $(endd_label).prop("class", "enddLabel");
    $(endd_label).html(qenddate);
    $(endd_div).html(endd_label);

    $(listDiv).append(t_div);
    $(listDiv).append(startd_div);
    $(listDiv).append(endd_div);
    $(listObj).append(listDiv);
    $("#validTerminalList").append(listObj);
}

function toggleToByReg() {
    $("#byRegistration").toggle(true);
    $("#byMovement").toggle(false);
}

function toggleToByMove() {
    $("#byRegistration").toggle(false);
    $("#byMovement").toggle(true);
}

function addDateTimeRange() {
    var dateStart = $("#qstartdatetime").val();// value in real time // DOM-live value , Static-web value
    var dateEnd = $("#qenddatetime").val();
    var beds = $("#querybeds").val();
    var listObj = document.createElement("LI");

    //startDate
    var ds_div = document.createElement("div");
    $(ds_div).prop("class", "dateStartDiv");//inserting data
    $(ds_div).prop("style", "float: left");
    var ds_label = document.createElement("label");
    $(ds_label).prop("class", "dateStartLabel");//inserting data
    $(ds_label).html(dateStart);//replacing the entire inner html
    $(ds_div).html(ds_label);//replacing the entire inner html

    //endDate
    var de_div = document.createElement("div");
    $(de_div).prop("class", "dateEndDiv");
    $(de_div).prop("style", "float: center");
    var de_label = document.createElement("label");
    $(de_label).prop("class", "dateEndLabel");
    $(de_label).html(dateEnd);
    $(de_div).html(de_label);

    //beds
    var beds_div = document.createElement("div");
    $(beds_div).prop("class", "bedsDiv");
    $(beds_div).prop("style", "float: right");
    var beds_label = document.createElement("label");
    $(beds_label).prop("class", "bedsLabel");
    $(beds_label).html(beds);
    $(beds_div).html(beds_label);
    

    $(listObj).append(ds_div);// add on to html
    $(listObj).append(de_div);
    $(listObj).append(beds_div);
    $("#querylist").append(listObj);
}

function submitQueries() {
    var queryDates = "";
    $("#querylist .qtem").each(function (idx, li) {
        var qstart = $(li).find(".dateStartLabel");
        var qitem_sd = $(qstart).val();//Get value

        var qend = $(li).find(".dateEndLabel");
        var qitem_ed = $(qend).val();

        var qbed = $(li).find(".bedsLabel");
        var qitem_bed = $(qbed).val();

        thisQuery = qitem_sd + '~~' + qitem_ed + '~~' + qitem_bed
        queryDates += thisQuery + "@@@";
    });

    var headersToProcess = { action: "traceByBed", queries: queryDates};
    $.ajax({
        url: toTracing,
        method: 'post',
        data: headersToProcess,
        success: function (returner) {
            traceQuery = JSON.parse(returner);
            var tracearr = [];
            tracearr = traceQuery.queryResults;
            for (index = 0; index < tracearr.length; ++index) {
                writeTraceResult(tracearr[index]);
            }
        },
        error: function (err) {
            alert(serverAjaxFailureError);
        },
    });
}

function writeTraceResult(resultItem) {
    var resultListObj = document.createElement("LI");

    //queryResultItem
    var ri_div = document.createElement("div");
    $(ri_div).prop("class", "resultItemDiv");
    var de_label = document.createElement("label");
    $(ri_label).prop("class", "resultItemLabel");
    $(ri_label).html(resultItem);
    $(ri_div).html(ri_label);

    $(resultListObj).append(ri_div);
    $("#resultList").append(resultListObj);
}