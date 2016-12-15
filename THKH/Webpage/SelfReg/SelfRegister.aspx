<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="SelfRegister.aspx.cs" Inherits="THKH.Webpage.SelfReg.SelfRegister" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>AMKTHKH Visitor Self-Registration</title>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <link href="~/Content/bootstrap.min.css" rel="stylesheet" />
    <script type="text/javascript" src="<%= Page.ResolveClientUrl("~/Scripts/jquery-3.1.1.min.js") %>"></script>
    <script type="text/javascript" src="<%= Page.ResolveClientUrl("/Scripts/moment.min.js") %>"></script>
    <script type="text/javascript" src="<%= Page.ResolveClientUrl("~/Scripts/bootstrap.min.js") %>"></script>
    <script type="text/javascript" src="<%= Page.ResolveClientUrl("/Scripts/bootstrap-datetimepicker.js") %>"></script>
    <style type="text/css">
    .buttonedge {
        border-top-left-radius: 4px; border-bottom-left-radius: 4px
    }
    .contentNav {
  display: inline-block;
  float: none;
  vertical-align: top;
   text-align: center;
   margin-bottom:0;
}
    .modal {
  text-align: center;
  padding: 0!important;
}



.modal:before {
  content: '';
  display: inline-block;
  height: 100%;
  vertical-align: middle;
  margin-right: -4px;
}

.modal-dialog {
  display: inline-block;
  text-align: left;
  vertical-align: middle;
}

.scrollToTop{
	width:100px; 
	height:130px;
	padding:10px; 
	text-align:center; 
	background: whiteSmoke;
	font-weight: bold;
	color: #444;
	text-decoration: none;
	position:fixed;
	top:75px;
	right:40px;
	display:none;
	background: url('arrow_up.png') no-repeat 0px 20px;
}
.scrollToTop:hover{
	text-decoration:none;
}
    </style>
</head>
<body onload="hideTags()">
    <form id="selfregistration" runat="server">
        <div id="maincontainer" class="container-fluid" runat="server">
            <nav class="navbar navbar-default navbar-fixed-top">
                <div class="container-fluid contentNav">
                    <div class="navbar-header ">
                        <a class="navbar-brand"><b>Thye Hua Kwan Hospital</b></a>
                    </div>
                </div>
            </nav>
            <br />
            <br />
            <br />
            <a data-controls-modal="myModal" data-backdrop="static" data-keyboard="false" href="#/">
                <div class="modal fade" id="myModal" tabindex="-1" role="dialog" aria-labelledby="memberModalLabel" aria-hidden="true">
                    <div class="modal-dialog">
                        <div class="modal-content">
                            <div class="modal-header text-center">
                                <img src="../../Assets/hospitalLogo.png" class="img img-responsive" /><br />
                                <h4 class="modal-title" id="memberModalLabel">Please enter your NRIC/Identification Number to Begin</h4>
                            </div>
                            <div class="modal-body text-center">
                                    NRIC: <input type="text" id="selfRegNric" class="form-control" autofocus/>
                                <h4 id="emptyNricWarning">Please enter your NRIC/Identification Number!</h4>
                            </div>
                            <div class="modal-footer">
                                <input type="submit" class="btn btn-block btn-success" id="submitNric" onclick="checkIfExistingVisitor(); false;" value="Submit"/>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="col-md-6 col-md-offset-3">
                    <h4 id="emptyFields" style="color:red">Please fill in all the required fields (*).</h4>
                    <div class="row">
                        <div id="newusercontent" runat="server">
                            <div class="jumbotron" style="text-align:left">
                                    <h3>Personal Details</h3>
                                    <label for="namesinput">Full Name</label><label for="existnric" id="comp1" style="color:red">*</label>
                                    <div class="form-group">
                                        <input type="text" runat="server" class="form-control required" id="namesInput" />
                                    </div>
                                    <label for="emailinput">Email address</label>
                                    <div class="form-group">
                                        <input type="text" runat="server" class="form-control" id="emailsInput" />
                                    </div>
                                    <label for="nricsInput">NRIC</label><label for="existnric" id="comp2" style="color:red">*</label>
                                    <div class="form-group">
                                        <input type="text" runat="server" class="form-control required" id="nricsInput" /><label for="nricsInput" id="nricWarning" style="color: red">Invalid/Non-Singapore Based ID!</label>
                                    </div>
                                    <label for="mobileinput">Mobile Number</label><label for="mobileinput" id="comp0" style="color:red">*</label>
                                    <div class="form-group">
                                        <input type="text" runat="server" class="form-control required" id="mobilesInput" />
                                    </div>
                                    <label for="homeinput">Home Number</label>
                                    <div class="form-group">
                                        <input type="text" runat="server" class="form-control" id="homesInput" />
                                    </div>
                                    <label for="altInput">Alternate Number</label>
                                    <div class="form-group">
                                        <input type="text" runat="server" class="form-control" id="altInput" />
                                    </div>
                                    <label for="addressinput">Address</label><label for="existnric" id="comp4" style="color:red">*</label>
                                    <div class="form-group">
                                        <input type="text" runat="server" class="form-control required" id="addresssInput" />
                                    </div>
                                    <label for="postalinput">Postal Code</label><label for="existnric" id="comp5" style="color:red">*</label>
                                    <div class="form-group">
                                        <input type="text" runat="server" class="form-control required" id="postalsInput" />
                                    </div>
                                    <label for="sexinput">Gender:</label><label for="existnric" id="comp5" style="color:red">*</label>
                                    <div class="form-group">
                                        <select class="form-control" id="sexinput">
                                            <option value="Male">Male</option>
                                            <option value="Female">Female</option>
                                        </select>
                                    </div>
                                    <label for="nationalinput">Nationality</label><label for="existnric" id="comp6" style="color:red">*</label>
                                    <div class="form-group">
                                        <input type="text" runat="server" class="form-control required" id="nationalsInput" />
                                    </div>
                                    <label for="daterange">Date of Birth</label><label for="existnric" id="comp7" style="color:red">*</label>
                                    <div class="input-group date" id="datetimepicker">
                                        <input type='text'id="daterange" class="form-control required" />
                                        <span class="input-group-addon">
                                            <span class="glyphicon glyphicon-calendar"></span>
                                        </span>
                                    </div>
                                </div>
                            </div>
                        <div id="staticinfocontainer" runat="server">
                            <div class="jumbotron" style="text-align:left">
                                <div id="changeddetailsdeclaration">
                            <label for="changeddetails">I have changed my contact details since the last visit</label> <%--Visitor Fever Declaration, can be a checkbox or an input field or a button--%>
                                <div class="form-group">
                                <div class="checkbox" id="changeddetails">
                                    <label for="yesopt">
                                    <input type="checkbox" id="changed" onchange="amendVisitorDetails()" name="yesopt" value="Yes" />Yes</label>
                                </div></div>
                                    </div>
                            <h3>Visit Details</h3>
                                <label for="pInput">Visit Purpose</label> <%--Check for Purpose of Visit--%>
                                <div class="form-group">
                                    <select class="form-control" id="pInput" onchange="purposePanels()">
                                        <option value="">-- Select One --</option>
                                        <option value="Visit Patient">Visit Patient</option>
                                        <option value ="Other Purpose">Other Purpose</option>
                                        </select>
                                    </div>
                                <div id="patientpurposevisit" class="container-fluid" runat="server"> <%--Show this only when Visit Purpose is "Visit Patient"--%>
                                    <label for="patientName">Patient Name</label> <%--AJAX Call to search for Patient Name--%>
                                    <div class="form-group">
                                        <input type="text" runat="server" class="form-control" id="patientName" />
                                    </div>
                                    <label for="patientNric">Patient NRIC</label>
                                    <div class="form-group">
                                        <input type="text" runat="server" class="form-control" id="patientNric" />
                                    </div>
                                    <label for="bedno">Bed Number:</label> <%--Bed Number--%>
                                <div class="form-group">
                                    <input type="text" runat="server" class="form-control" id="bedno" />
                                </div>
                                <input type="button" id="validatePatientButton" value="Validate Patient Information" class="btn btn-warning" onclick="validatePatient(); false;" />
                                </div>
                                <div id="otherpurposevisit" class="container-fluid" runat="server"> <%--Show this only when Visit Purpose is "Other Purpose"--%>
                                    <label for="visLoc">Visit Location</label> 
                                    <div class="form-group">
                                    <select class="form-control" id="visLoc">
                                        <option name="none" value="">-- Select One --</option>
                                        <option name="canteen" value="canteen">Canteen</option>
                                        </select>
                                    </div>
                                    <label for="purposeInput">Purpose of Visit</label> 
                                    <div class="form-group">
                                        <input type="text" runat="server" class="form-control" id="purposeInput" />
                                    </div>
                                </div>
                                <label for="visitbookingdate">Visit Date</label><label for="visitbookingdate" id="comp21" style="color: red">*</label>
                                <%--Visit Time--%>
                                    <div class="input-group date" id="visitbookingdatediv">
                                    <input type='text' id="visitbookingdate" class="form-control required" />
                                    <span class="input-group-addon">
                                        <span class="glyphicon glyphicon-calendar"></span>
                                    </span>
                                </div>
                                <label for="visitbookingtime">Visit Time</label><label for="visitbookingtime" id="comp11" style="color: red">*</label>
                                <%--Visit Time--%>
                                    <div class="input-group date" id="visitbookingtimediv">
                                    <input type='text' id="visitbookingtime" class="form-control required" />
                                    <span class="input-group-addon">
                                        <span class="glyphicon glyphicon-time"></span>
                                    </span>
                                </div>
                                <h3>Health Screening Questionnaire</h3>
                                <label for="fevdiv">Do you have a Fever?</label> <%--Visitor Fever Declaration, can be a checkbox or an input field or a button--%>
                                <div class="form-group">
                                <div class="checkbox" id="fevdiv">
                                    <label for="yesopt">
                                    <input type="checkbox" id="fever" name="yesopt" value="Yes" />Yes</label>
                                </div>
                                    </div>
                                <label for="symptomInput">I possess the following symptom(s)</label> <%--Patient Symptom declaration--%>
                                <div class="form-group">
                                    <div id="symptomInput" class="checkbox">
                                        <label for="one">
                                            <input type="checkbox" id="pimple" value="Pimple" />Pimple</label>
                                        <label for="two">
                                            <input type="checkbox" id="hairloss" value="Hair Loss" />Hair Loss</label>
                                    </div>
                                </div>
                                <label for="symdiv">Do you have any close contact with person or persons returning from INFLUENZA [FLU] INFECTED countries?</label>
                                <div id="symdiv" class="checkbox">
                                        <label for="one">
                                            <input type="checkbox" id="flu" value="Yes" />Yes</label>
                                </div>
                                <label for="visitInput">Countries Travelled For The Past 2 Weeks </label>
                                <div class="form-group">
                                    <div id="checkboxes" class="checkbox">
                                        <label for="one">
                                            <input type="checkbox" id="sg" value="Singapore" />Singapore</label>
                                        <label for="two">
                                            <input type="checkbox" id="mi" value="Malaysia" />Malaysia</label>
                                        <label for="three">
                                            <input type="checkbox" id="cn" value="China" />China</label>
                                    </div>
                                </div>
                                <label for="remarksinput">Remarks:</label>
                                <div class="form-group">
                                    <input type="text" runat="server" class="form-control" id="remarksinput" />
                                </div>
                                <div class="checkbox">
                                    <label for="declaration">
                            <input type="checkbox" id="declaration" name="declare" onchange="declarationValidation()" value="true" />I declare that the above information given is accurate</label><br />
                                    <input type="hidden" name="declare" value="false" />
                            <label for="declaration" id="declabel" style="color:red">Please check this option to continue</label>
                        </div>
                        <input class="btn btn-block btn-success" type="button" id="submitNewEntry" runat="server" onclick="checkRequiredFields(); false;" value="Submit"/> <%--Copy to Tables without confirmation--%>

                        </div>
                            </div>
                    </div>
                </div>
                </div>
    </form>
    <script type="text/javascript" src="<%= Page.ResolveClientUrl("~/Scripts/fieldValidations.js") %>"></script>
    <script type="text/javascript">
        $(window).load(function () {
            //if (sessionStorage["PopupShown"] != 'yes') {
                $('#myModal').modal('show');
               // sessionStorage["PopupShown"] = 'yes';
            //}
        });

        $("#selfregistration").submit(function (e) {
            e.preventDefault();
        });

        function showNricWarning() {
            emptyNricWarning$('#emptyNricWarning').css("display", "block");
        }

            function checkRequiredFields(){
                var valid = true;
                $.each($("#selfregistration input.required"), function (index, value) {
                    if (!$(value).val()) {
                        valid = false;
                    }
                });
                if (valid) {
                    $('#emptyFields').css("display", "none");
                    NewSelfReg();
                }
                else {
                    $('#emptyFields').css("display", "block");
                }
            }

            function showModal() {
                $('#myModal').modal('show');
            }

            function hideModal() {
                $('#myModal').modal('hide');
            }

            function showNewContent(nricValue) {
                //$("#nricsInput").val(nricValue);
                $('#newusercontent').css("display", "block");
                $('#staticinfocontainer').css("display", "block");
                hideModal();
            }

            // Show only the Visit Purpose & Questionnaire
            function showExistContent(nricValue) {
                $('#changeddetailsdeclaration').css("display", "block");
                $('#staticinfocontainer').css("display", "block");
                hideModal();
            }

            // Display Submit Button according to whether the user has checked the declaration checkbox
            function declarationValidation() {
                if ($("#declaration").prop('checked') == true) {
                    $("#declabel").css("display", "none");
                    $("#submitNewEntry").css("display", "block");
                } else {
                    $("#declabel").css("display", "block");
                    $("#submitNewEntry").css("display", "none");
                }
            }

            // Datetime Picker JQuery
            $(function () {
                $('#datetimepicker').datetimepicker({
                    // dateFormat: 'dd-mm-yy',
                    defaultDate: new Date(),
                    format: 'DD-MM-YYYY'
                });
                $('#visitbookingtimediv').datetimepicker(
                    {
                        // dateFormat: 'dd-mm-yy',
                        defaultDate: new Date(),
                        format: 'HH:mm'
                    });
                $('#visitbookingdatediv').datetimepicker(
                    {
                        // dateFormat: 'dd-mm-yy',
                        defaultDate: new Date(),
                        format: 'DD-MM-YYYY'
                    });
            });

            $("#nricsInput").on("input", function () {
                var validNric = validateNRIC($("#nricsInput").val());
                if (validNric !== false) {
                    $("#nricWarning").css("display", "none");
                } else {
                    $("#nricWarning").css("display", "block");
                }
            });

            function purposePanels() {
                var purpose = $("#pInput").val();
                if (purpose === "Visit Patient") {
                    $("#patientpurposevisit").css("display", "block");
                    $("#otherpurposevisit").css("display", "none");
                } else if (purpose === "Other Purpose") {
                    $("#patientpurposevisit").css("display", "none");
                    $("#otherpurposevisit").css("display", "block");
                } else {
                    $("#patientpurposevisit").css("display", "none");
                    $("#otherpurposevisit").css("display", "none");
                }
            }

            function amendVisitorDetails() {
                if ($("#changed").prop('checked') == true) {
                    $('#newusercontent').css("display", "block");
                } 
            }

            function hideTags() {
                //$('#existingusercontent').css("display", "none");
                $('#emptyNricWarning').css("display", "none");
                $('#staticinfocontainer').css("display", "none");
                $('#changeddetailsdeclaration').css("display", "none");
                $('#newusercontent').css("display", "none");
                $("#nricWarning").css("display", "none");
                $("#nricexistlabel").css("display", "none");
                $("#patientpurposevisit").css("display", "none");
                $("#otherpurposevisit").css("display", "none");
                $("#nricnotexistlabel").css("display", "none");
                $("#submitNewEntry").css("display", "none");
                $('#emptyFields').css("display", "none");
            }
    </script>
    <script type="text/javascript" src="<%= Page.ResolveClientUrl("~/Scripts/selfRegistrationScript.js") %>"></script>
    <input type="hidden" id="isNew" value="true" />
</body>
</html>
