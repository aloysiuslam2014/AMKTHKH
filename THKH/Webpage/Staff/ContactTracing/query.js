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

// Change checkbox value upon click
$('#expressTraceCheck').on('change', function () {
    this.check;
    var isChecked = $('input[id="expressTraceCheck"]').is(':checked');
    if (isChecked) {
        $("#uq_bednos").prop("disabled", true);
        $("#uq_loc").prop("disabled", true);
    } else {
        $("#uq_bednos").prop("disabled", false);
        $("#uq_loc").prop("disabled", false);
    }
});

//
function unifiedTrace() {
    var resultTable = document.getElementById("uq_resultstable_body");
    var expTrc = $('input[id="expressTraceCheck"]').is(':checked');
    if (expTrc) {
        expressTrace();
    }
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
                var dashResult = returner
                var result_json = JSON.parse(dashResult); //list of json objects, one for each chart
                var dayOfWeek_json = result_json[0];
                var hourOfDay_json = result_json[1];
                var dwelltime_json = result_json[2];
                var gender_json = result_json[3];
                var age_json = result_json[4];
                var location_json = result_json[5];

                var hourOfDay_chart = new CanvasJS.Chart("hourOfDay_chart",
                {
                    title: {
                        text: "Check-ins per hour"
                    },
                    axisX: {
                        interval: 1,
                        labelFontSize: 12
                    },
                    data: [
                    {
                        type: "column",
                        dataPoints: hourOfDay_json
                    }
                    ]
                });

                hourOfDay_chart.render();

                var dayOfweek_chart = new CanvasJS.Chart("dayOfWeek_chart",
                {
                    title: {
                        text: "Check-ins per day"
                    },
                    data: [
                    {
                        type: "column",
                        dataPoints: dayOfWeek_json
                    }
                    ]
                });

                dayOfweek_chart.render();

                var age_chart = new CanvasJS.Chart("age_chart",
                {
                    title: {
                        text: "Visitor age range"
                    },
                    data: [

                    {
                        type: "column",
                        dataPoints: age_json
                    }
                    ]
                });

                age_chart.render();

                var gender_chart = new CanvasJS.Chart("gender_chart",
                {
                    title: {
                        text: "Visitor gender"
                    },
                    data: [

                    {
                        type: "column",
                        dataPoints: gender_json
                    }
                    ]
                });

                gender_chart.render();

                var dwelltime_chart = new CanvasJS.Chart("dwelltime_chart",
                {
                    title: {
                        text: "Visit Duration"
                    },
                        axisX: {
                            labelAngle: -30,
                            interval: 1
                    },
                    data: [

                    {
                        type: "column",
                        dataPoints: dwelltime_json
                    }
                    ]
                });

                dwelltime_chart.render();

                var location_chart = new CanvasJS.Chart("location_chart",
                {
                    title: {
                        text: "Visitors per location"
                    },
                    axisX: {
                        interval: 1
                    },
                    data: [
                    {
                        type: "column",
                        dataPoints: location_json
                    }
                    ]
                });

                location_chart.render();

            } catch (err) {
                alert("Something went wrong when retrieving dashboard data. " + err);
            }
        },
        error: function (err) {
            alert("Something Ajaxsploded, please contact the admin.");
        },
    });
}

// Date time picker
$(function () {
    $('#unifiedquery_startdatetime').datetimepicker(
        {
            defaultDate: new Date(),
            maxDate: 'now',
            format: 'YYYY-MM-DD'
        }
        );
    $('#unifiedquery_enddatetime').datetimepicker({
        defaultDate: new Date(),
        maxDate: 'now',
        format: 'YYYY-MM-DD'
    });
});