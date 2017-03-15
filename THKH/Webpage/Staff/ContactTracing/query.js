var toTracing = './ContactTracing/TracingGateway.ashx';
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