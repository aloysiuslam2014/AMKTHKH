var resultsCall = null;
var resultsRetrieved = null;
var checkAutoTime = null;

function bedSearch(bed) {
    if ($(bed).val().toString().length == 4) {
        updatePatientSearch(0, $(bed).val());
    }
}

function nameSearch(name) {
    if ($(name).val().toString().length > 0) {
        if (checkAutoTime != null)
            clearTimeout(checkAutoTime);

        checkAutoTime = setTimeout(function () {
            $("#searchResultsDiv").html("");
            $("#searchResultsDiv").toggle(true);
            updatePatientSearch(1, $(name).val());
        }, 500);
      
    }else{
        $("#searchResultsDiv").toggle(false);
        if (checkAutoTime != null)
            clearTimeout(checkAutoTime);
    }
   
}

function runSearch() {
   
}

function updatePatientSearch(isName,toSearch) {
    //run ajax. Cancel ajax prev calls
    if (resultsCall != null) {
        resultsCall.abort();
    }
    var headersToProcess = {
        requestType: "searchName",
        isNameSearch:isName,
        searchData: toSearch
    };
    resultsCall = $.ajax({
        url: regUrl, //From registrationpagescript
        method: 'post',
        data: headersToProcess,


        success: function (returner) {
            resultOfGeneration = JSON.parse(returner);
            var res = resultOfGeneration.Msg;
            if (res.toString() == "Success") {
                if (isName == 1) {
                    updateSearchName(resultOfGeneration.Result);
                } else {
                    insertSearchName(resultOfGeneration.Result);
                }
                
                //initialLoadCompleted = true;
            } else {
                alert(resultOfGeneration.Result);
            }
        },
        error: function (err) {
            alert(err.Msg);
        },
    });
}

function updateSearchName(results) {
    
    for (var i = 0; i < results.length;i++) {
        var name = results[i].split(',')[0];
        var id = results[i].split(',')[1];
        var lblName = document.createElement("label");
        var br = document.createElement("br");
        $(lblName).html(name);
        $(lblName).attr("id", id);
        $(lblName).addClass("autocompleteItem");
        $(lblName).on("click", function () {
            var nameSelected = $(this).html();
            var selectedBed = $(this).attr("id");
            $("#patientName").val(nameSelected);
            $("#bedno").val(selectedBed);
            $("#searchResultsDiv").toggle(false);
        });
        //attach eventlistener so on click get label text and hide search field
        $("#searchResultsDiv").append(lblName);
        $("#searchResultsDiv").append(br);
    }

    if (results.length == 0) {
        $("#searchResultsDiv").html("No match found.");
    }

}


function insertSearchName(result) {
    if (result.length == 0) {
        $("#patientName").val("Bed number not found.");
    } else {
        $("#patientName").val(result[0].split(',')[0]);
    }
   
}