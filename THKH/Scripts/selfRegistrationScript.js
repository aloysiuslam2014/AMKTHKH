function NewSelfReg() {
    var fname = $("#namesInput").val();
    var snric = $("#nricsInput").val();
    var address = $("#addresssInput").val();
    var postal = $("#postalsInput").val();
    var mobtel = $("#mobilesInput").val();
    var alttel = $("#altInput").val();
    var hometel = $("#homesInput").val();
    var sex = $("#sexinput").val();
    var nationality = $("#nationalsInput").val();
    var dob = $("#daterange").val(); // Format date
    var race = "Chinese";
    var age = 23;
    var Email = $("#emailsInput").val();
    var purpose = $("#pInput").val();
    var pName = $("#patientName").val();
    var pNric = $("#patientNric").val();
    var otherPurpose = $("#purposeInput").val();
    var bedno = $("#bedno").val();
    var visTime = $("#visitbookingtime").val();
    var visDate = $("#visitbookingdate").val();
    var appTime = visDate + " " + visTime;
    var fever = $("#fever").val();
    var symptoms = $("#pimple").val();
    var influenza = $("#flu").val();
    var countriesTravelled = $("#sg").val();
    var remarks = $("#remarksinput").val();
    var visitLoc = $("#visLoc").val();

    var headersToProcess = {
        fullName: fname, nric: snric, ADDRESS: address, POSTAL: postal, MobTel: mobtel, email: Email,
        AltTel: alttel, HomeTel: hometel, SEX: sex, Natl: nationality, DOB: dob, RACE: race, AGE: age, PURPOSE: purpose, pName: pName, pNric: pNric,
        otherPurpose: otherPurpose, bedno: bedno, appTime: appTime, fever: fever, symptoms: symptoms, influenza: influenza,
        countriesTravelled: countriesTravelled, remarks: remarks, visitLocation: visitLoc, requestType: "self"
    };
    $.ajax({
        url: '../Staff/CheckInOut/checkIn.ashx', // Change Path
        method: 'post',
        data: headersToProcess,


        success: function (returner) {
            var resultOfGeneration = JSON.parse(returner);
            if (resultOfGeneration.Result === "Success") {
                alert("Error: " + resultOfGeneration.Msg);
            } else {
                var today = new Date();
                alert("Your online registration has been recorded at " + today.getDay() + "/" + today.getMonth() + "/" + today.getYear() + " " + today.getHours() + ":" + today.getMinutes());
            }  
        },
        error: function (err) {
        },
    });
}

function validatePatient() {
    // Logic to validate patient with THK Patient DB. If patient is valid, set a global variable to enable the submit button of the form
}

function checkIfExistingVisitor() {
    var snric = $("#selfRegNric").val();
    if (snric === "") {
        showNricWarning();
    } else {
        var resultOfGeneration = "";
        var headersToProcess = {
            nric: snric, requestType: "getdetails"
        };
        $.ajax({
            url: '../Staff/CheckInOut/checkIn.ashx', // Change path
            method: 'post',
            data: headersToProcess,


            success: function (returner) {
                resultOfGeneration = JSON.parse(returner);
                var res = resultOfGeneration.Msg;
                if (resultOfGeneration.Msg.includes("0")) {
                    showNewContent(snric);
                }
                else {
                    showExistContent(snric);
                }
                $('#nricsInput').attr('value', snric);
            },
            error: function (err) {
                alert(err.Msg);
            },
        });
        
        
    }
}