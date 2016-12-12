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
    var dob = $("#daterange").val();
    var race = "Chinese";
    var age = 23;
    var Email = $("#emailsInput").val();
    var purpose = $("#pInput").val();
    var pName = $("#patientName").val();
    var pNric = $("#patientNric").val();
    var otherPurpose = $("#purposeInput").val();
    var bedno = $("#bedno").val();
    var appTime = $("#visitbookingtime").val();
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
        countriesTravelled: countriesTravelled, remarks: remarks, visitLocation: visitLoc, typeOfRequest: "self"
    };
    $.ajax({
        url: './CheckInOut/checkIn.ashx',
        method: 'post',
        data: headersToProcess,


        success: function (returner) {
            var resultOfGeneration = JSON.parse(returner);
            alert(resultOfGeneration.Msg);
        },
        error: function (err) {
        },
    });
}

function checkIfExistingVisitor() {
    var snric = $("#selfRegNric").val();
    var headersToProcess = {
        firstName: "", nric: snric, ADDRESS: "", POSTAL: "", MobTel: "", email: "",
        AltTel: "", HomeTel: "", SEX: "", Natl: "", DOB: "", RACE: "", AGE: "", PURPOSE: "", pName: "", pNric: "",
        otherPurpose: "", bedno: "", appTime: "", fever: "", symptoms: "", influenza: "",
        countriesTravelled: "", remarks: "", visitLocation: "", typeOfRequest: "getdetails"
    };
    $.ajax({
        url: './CheckInOut/checkIn.ashx',
        method: 'post',
        data: headersToProcess,


        success: function (returner) {
            var resultOfGeneration = JSON.parse(returner);
            alert(resultOfGeneration.Msg);
        },
        error: function (err) {
        },
    });
    //If Existing, Populate Fields & hide details
    //showExistContent(snric);
    //Else, show whole form
    showNewContent(snric);
}