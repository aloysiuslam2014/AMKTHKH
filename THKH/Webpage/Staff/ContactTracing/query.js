var toTracing = './ContactTracing/TracingGateway.ashx';
var selfRegNoDataError = "Selected period returns no data. Please try another date";
var serverAjaxFailureError = "There was a problem retrieving valid terminals.";


var visitors, visitDetails;
var uq_bednos = document.getElementById("uq_bednos");
var uq_loc = document.getElementById("uq_loc");

//
function enableToggle(current, other) {

    other.disabled = current.value.replace(/\s+/, '').length > 0;

}

//
function expressTrace() {
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
    uq_params = uq_dateStart + '~' + uq_dateEnd;

    var headersToProcess = { action: "expressTrace", queries: uq_params };
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

//
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

//
function writeUQResultsTable(uqResultJSON) {
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

//
function fillDashboard() {

    var dash_dateStart = $("#dash_startdatetime").val();
    var dash_dateEnd = $("#dash_enddatetime").val();

    var _dateStart = new Date(dash_dateStart);
    var _dateEnd = new Date(dash_dateEnd);

    if (_dateStart > _dateEnd) {
        alert("End date of query period must be before start date!");
        return;
    }

    dash_params = dash_dateStart + '~' + dash_dateEnd;

    var headersToProcess = { action: "fillDashboard", queries: dash_params };
    $.ajax({
        url: toTracing,
        method: 'post',
        data: headersToProcess,

        success: function (returner) {
            try {
                var dashResult = JSON.parse(returner); //list of json objects
                alert("Woo! temporary success message. ");
            } catch (err) {
                alert("Something went wrong when retrieving dashboard data. " + err);
            }

        },
        error: function (err) {
            alert("Something Ajaxsploded, please contact the admin.");
        },
    });
}