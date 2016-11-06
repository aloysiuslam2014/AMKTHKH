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
            <a data-controls-modal="myModal" data-backdrop="static" data-keyboard="false" href="#">
                <button type="button" class="btn btn-success btn-block" data-toggle="modal" data-target="#myModal">Choose User</button>
                <div class="modal fade" id="myModal" tabindex="-1" role="dialog" aria-labelledby="memberModalLabel" aria-hidden="true">
                    <div class="modal-dialog">
                        <div class="modal-content">
                            <div class="modal-header">
                                <%--<button type="button" class="close" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">&times;</span></button>--%>
                                <img src="../../Assets/hospitalLogo.png" class="img img-responsive" />
                                <h4 class="modal-title" id="memberModalLabel">Select an Option to Begin Self-Registration</h4>
                            </div>
                            <div class="modal-body">
                                <div class="btn-group">
                                    <%-- <button type="button" class="btn btn-primary" onclick="showNewContent()">New Visitor</button>--%>
                                    <button type="button" id="NewVisitorButton" class="btn btn-primary" onclick="newVis()">New Visitor</button>
                                    <%--                            <button type="button" class="btn btn-primary" onclick="showExistContent()">Existing Visitor</button>--%>
                                    <button type="button" id="ExistingVisitorButton" class="btn btn-primary" onclick="exiVis()">Existing Visitor</button>
                                </div>
                            </div>
                            <div class="modal-footer">
                                <%--<button type="button" class="btn btn-danger" data-dismiss="modal">Close</button>--%>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="container-fluid">
                    <div class="row">
                        <div id="newusercontent" class="col-sm-6" runat="server">
                            <div class="jumbotron" style="text-align:left">
                                    <h3>Personal Details</h3>
                                    <label for="namesinput">First Name:</label>
                                    <div class="form-group">
                                        <input type="text" runat="server" class="form-control" id="namesInput" />
                                    </div>
                                    <label for="lnamesinput">Last Name:</label>
                                    <div class="form-group">
                                        <input type="text" runat="server" class="form-control" id="lnamesInput" />
                                    </div>
                                    <label for="emailinput">Email address:</label>
                                    <div class="form-group">
                                        <input type="text" runat="server" class="form-control" id="emailsInput" />
                                    </div>
                                    <label for="nricsInput">NRIC:</label>
                                    <div class="form-group">
                                        <input type="text" runat="server" class="form-control" id="nricsInput" /><label for="nricsInput" id="nricWarning" style="color: red">Invalid/Non-Singapore Based ID!</label>
                                    </div>
                                    <label for="mobileinput">Mobile Number:</label>
                                    <div class="form-group">
                                        <input type="text" runat="server" class="form-control" id="mobilesInput" />
                                    </div>
                                    <label for="homeinput">Home Number:</label>
                                    <div class="form-group">
                                        <input type="text" runat="server" class="form-control" id="homesInput" />
                                    </div>
                                    <label for="altInput">Alternate Number:</label>
                                    <div class="form-group">
                                        <input type="text" runat="server" class="form-control" id="altInput" />
                                    </div>
                                    <label for="addressinput">Address:</label>
                                    <div class="form-group">
                                        <input type="text" runat="server" class="form-control" id="addresssInput" />
                                    </div>
                                    <label for="postalinput">Postal Code:</label>
                                    <div class="form-group">
                                        <input type="text" runat="server" class="form-control" id="postalsInput" />
                                    </div>
                                    <label for="sexinput">Gender:</label>
                                    <div class="form-group">
                                        <select class="form-control" id="sexinput">
                                            <option value="Male">Male</option>
                                            <option value="Female">Female</option>
                                        </select>
                                    </div>
                                    <label for="nationalinput">Nationality:</label>
                                    <div class="form-group">
                                        <input type="text" runat="server" class="form-control" id="nationalsInput" />
                                    </div>
                                    <label for="daterange">Date of Birth:</label>
                                    <div class="input-group date" id="datetimepicker">
                                        <input type='text'id="daterange" class="form-control" />
                                        <span class="input-group-addon">
                                            <span class="glyphicon glyphicon-calendar"></span>
                                        </span>
                                    </div>
                                </div>
                            </div>
                        <div id="existingusercontent" class="col-sm-6" runat="server">
                            <div class="jumbotron" style="text-align:left">
                            <h3>Please Enter your NRIC</h3>
                            <div class="form-group">
                                <label for="existnric">NRIC:</label>
                                <input class="form-control" id="existnric" onchange="callCheckSelf(); false;"></input>
                                <label for="existnric" id="nricexistlabel" style="color:lightgreen">NRIC Found!</label>
                                <label for="existnric" id="nricnotexistlabel" style="color:red">NRIC Not Found! Please Register as a New Visitor or Approach the Registration Desk.</label>
                            </div>
                                </div>
                        </div>
                        <div id="staticinfocontainer" class="col-sm-6" runat="server">
                            <h3>Visit Details</h3>
                                <label for="pInput">Visit Purpose:</label> <%--Check for Purpose of Visit--%>
                                <div class="form-group">
                                    <select class="form-control" id="pInput" onchange="purposePanels()">
                                        <option value="-">-- Select One --</option>
                                        <option value="patient">Visit Patient</option>
                                        <option value ="other">Other Purpose</option>
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
                                <label for="visitbookingtime">Appointment Time:</label> <%--Appointment Time--%>
                                <div class="form-group">
                                    <select class="form-control" id="visitbookingtime">
                                        <option>0900</option>
                                        <option>0930</option>
                                        <option>1000</option>
                                        <option>1030</option>
                                        <option>1100</option>
                                        <option>1130</option>
                                        <option>1200</option>
                                        <option>1230</option>
                                        <option>1300</option>
                                        <option>1330</option>
                                        <option>1400</option>
                                        <option>1430</option>
                                        <option>1500</option>
                                        <option>1530</option>
                                        <option>1600</option>
                                        <option>1630</option>
                                        <option>1700</option>
                                        <option>1730</option>
                                        <option>1800</option>
                                        <option>1830</option>
                                        <option>1900</option>
                                        <option>1930</option>
                                        <option>2000</option>
                                    </select>
                                </div>
                                </div>
                                <div id="otherpurposevisit" class="container-fluid" runat="server"> <%--Show this only when Visit Purpose is "Other Purpose"--%>
                                    <label for="visLoc">Visit Location</label> 
                                    <div class="form-group">
                                    <select class="form-control" id="visLoc">
                                        <option name="canteen" value="canteen">Canteen</option>
                                        </select>
                                    </div>
                                    <label for="purposeInput">Purpose of Visit</label> 
                                    <div class="form-group">
                                        <input type="text" runat="server" class="form-control" id="purposeInput" />
                                    </div>
                                </div>
                                
                                <h3>Health Screening Questionnaire</h3>
                                <label for="fevdiv">Do you have a Fever?</label> <%--Visitor Fever Declaration, can be a checkbox or an input field or a button--%>
                                <div class="form-group">
                                <div class="checkbox" id="fevdiv">
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
                            <input type="checkbox" id="declaration" name="declare" onchange="declarationValidation()" value="true" />I declare that the above information given is accurate<br />
                                    <input type="hidden" name="declare" value="false" />
                            <label for="declaration" id="declabel" style="color:red">Please check this option to continue</label>
                        </div>
                        <input class="btn btn-success" type="submit" id="submitNewEntry" runat="server" onclick="NewSelfReg(); false;" value="Submit" />

                        </div>
                    </div>
                </div>
                </div>
    </form>
    <script type="text/javascript" src="<%= Page.ResolveClientUrl("~/Scripts/fieldValidations.js") %>"></script>
    <script type="text/javascript">
        $(window).load(function () {
            if (sessionStorage["PopupShown"] != 'yes') {
                $('#myModal').modal('show');
                sessionStorage["PopupShown"] = 'yes';
            }
        });

        function newVis() {
            showNewContent();
            showStaticContent();
            hideModal();
        }

        function exiVis() {
            showExistContent();
            showStaticContent();
            hideModal();
        }

        function showModal() {
            $('#myModal').modal('show');
        }

        function hideModal() {
            $('#myModal').modal('hide');
        }

        function showNewContent() {
            $('#newusercontent').css("display", "block");
            $('#existingusercontent').css("display", "none");
        }

        function showExistContent() {
            $('#existingusercontent').css("display", "block");
            $('#newusercontent').css("display", "none");
        }

        function showStaticContent() {
            $('#staticinfocontainer').css("display", "block");
        }

        $(function () {
            $('#datetimepicker').datetimepicker();
        });

        $("#nricsInput").on("input", function () {
            var validNric = validateNRIC($("#nricsInput").val());
            if (validNric !== false) {
                $("#nricWarning").css("display", "none");
            } else {
                $("#nricWarning").css("display", "block");
            }
        });

        function hideTags() {
            $('#existingusercontent').css("display", "none");
            $('#staticinfocontainer').css("display", "none");
            $('#newusercontent').css("display", "none");
            $("#nricWarning").css("display", "none");
            $("#nricexistlabel").css("display", "none");
            $("#nricnotexistlabel").css("display", "none");
        }

    </script>
    <script type="text/javascript" src="<%= Page.ResolveClientUrl("~/Scripts/registrationPageScripts.js") %>"></script>
    <input type="hidden" id="isNew" value="true" />
</body>
</html>
