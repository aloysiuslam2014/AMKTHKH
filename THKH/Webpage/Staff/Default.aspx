<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Default.aspx.cs" Inherits="THKH.Webpage.Staff.Default" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <meta charset="utf-8">
    <title>Welcome "username"</title>
    <link href="~/Content/bootstrap.min.css" rel="stylesheet" />
    <script type="text/javascript" src="<%= Page.ResolveClientUrl("~/Scripts/jquery-3.1.1.min.js") %>"></script>
    <script type="text/javascript" src="<%= Page.ResolveClientUrl("/Scripts/moment.min.js") %>"></script>
    <script type="text/javascript" src="<%= Page.ResolveClientUrl("~/Scripts/bootstrap.min.js") %>"></script>
    <script type="text/javascript" src="<%= Page.ResolveClientUrl("/Scripts/bootstrap-datetimepicker.js") %>"></script>

    <link href="~/CSS/default.css" rel="stylesheet" />





</head>
<body onload="hideTags()">

    <nav class="navbar navbar-default navbar-fixed-top">
        <div class="container-fluid">

            <div class="navbar-header">
                <button type="button" class="navbar-toggle collapsed" data-toggle="collapse" data-target="#navbar-W1LfPbp4DDBf1">
                    <span class="icon-bar"></span>
                    <span class="icon-bar"></span>
                    <span class="icon-bar"></span>
                </button>
                <a class="navbar-brand"><b>Thye Hua Kwan Hospital</b></a>
            </div>
            <div class="collapse navbar-collapse" id="navbar">
                <ul class="nav navbar-nav " id="navigatePage">
                    <li>
                        <a href="#registration" data-toggle="tab">Registration
                        </a>
                    </li>
                    <li>
                        <a href="#formManagement" data-toggle="tab">Form Management
                        </a>
                    </li>
                    <li>
                        <a href="#userManagement" data-toggle="tab">User Management
                        </a>
                    </li>
                </ul>

                <ul class="nav navbar-nav navbar-right">
                    <li><a id="logAnchor" href="#">
                        <form id="logbtn" runat="server">
                            <div>
                                <label>Welcome, user</label>
                                <asp:Button ID="logout" class="btn" Text="logout" OnClick="logout_Click" runat="server" />
                            </div>
                        </form>

                    </a></li>
                </ul>
            </div>
        </div>
    </nav>


    <div class="container containerMain">

        <div class="tab-content tab-content-main maxHeight" id="generalContent">

            <div class="tab-pane maxHeight" id="registration">

                <nav class="navbar navbar-default">
                    <div class="container-fluid " style="margin-top: 4px;">

                        <ul class="nav nav-pills contentNav" style="margin-bottom: 0;" id="regPageNavigation">

                            <li><a href="#checkIn" data-toggle='tab'>Check-In Visitor</a></li>
                            <li><a href="#regVisit" data-toggle='tab'>Register Visitor</a></li>

                        </ul>
                    </div>
                </nav>
                <div class="tab-content maxHeight" id="regContent">
                    <div class="tab-pane maxHeight" id="checkIn">
                        <div class="container center-block vertical-center">

                            <div class="toHoldElementsInContainer">
                                <div class="row padRows form-horizontal">
                                    <div class=" col-lg-4 col-lg-offset-4">

                                        <label class="control-label" for="nric">Visitor's NRIC:</label><input runat="server" id="nric" onchange="callCheck(); false;" class="form-control" type="text" />
                                        <input class="btn btn-default" type="submit" id="submitNricBtn" onclick="callCheck(); false;" runat="server" value="submit" />
                                    </div>
                                </div>
                                <div class=" row padRows" id="tempField">
                                    <div class="col-lg-4 col-lg-offset-4">
                                        Temperature:<input runat="server" id="temp" class="form-control" type="text" />
                                        <input class="btn btn-default" type="submit" id="checkInBtn" runat="server" onclick="CheckIn(); false;" value="Check-In" />
                                    </div>
                                </div>
                                <div class="row padRows">
                                    <div class="col-lg-10 col-lg-offset-1">
                                        <div id="Details" class="form-control userDetails">Waiting for input</div>

                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>

                    <div class="tab-pane maxHeight" id="regVisit" runat="server">
                        <div class="row maxHeight" style="overflow-y: auto">
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
                            <div id="staticinfocontainer" class="col-sm-6" style="text-align:left" runat="server">
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
                                </div>
                                <div id="otherpurposevisit" class="container-fluid" runat="server"> <%--Show this only when Visit Purpose is "Other Purpose"--%>
                                    <label for="purposeInput">Purpose of Visit</label> 
                                    <div class="form-group">
                                        <input type="text" runat="server" class="form-control" id="purposeInput" />
                                    </div>
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
                                <h3>Health Screening Questionnaire</h3>
                                <label for="fevdiv">Do you have a Fever?</label> <%--Visitor Fever Declaration, can be a checkbox or an input field or a button--%>
                                <div class="form-group">
                                <div class="checkbox" id="fevdiv">
                                    <input type="checkbox" name="yesopt" value="Yes" />Yes</label>
                                </div>
                                    </div>
                                <label for="symptomInput">I possess the following symptom(s)</label> <%--Patient Symptom declaration--%>
                                <div class="form-group">
                                    <div id="symptomInput" class="checkbox">
                                        <label for="one">
                                            <input type="checkbox" id="one" value="Pimple" />Pimple</label>
                                        <label for="two">
                                            <input type="checkbox" id="two" value="Hair Loss" />Hair Loss</label>
                                    </div>
                                </div>
                                <label for="symdiv">Do you have any close contact with person or persons returning from INFLUENZA [FLU] INFECTED countries?</label>
                                <div id="symdiv" class="checkbox">
                                        <label for="one">
                                            <input type="checkbox" id="one" value="Yes" />Yes</label>
                                </div>
                                <label for="visitInput">Countries Travelled For The Past 2 Weeks </label>
                                <div class="form-group">
                                    <div id="checkboxes" class="checkbox">
                                        <label for="one">
                                            <input type="checkbox" id="one" value="Singapore" />Singapore</label>
                                        <label for="two">
                                            <input type="checkbox" id="two" value="Malaysia" />Malaysia</label>
                                        <label for="three">
                                            <input type="checkbox" id="three" value="China" />China</label>
                                    </div>
                                </div>
                                <label for="remarksinput">Remarks:</label>
                                <div class="form-group">
                                    <input type="text" runat="server" class="form-control" id="remarksinput" />
                                </div>
                            </div>

                        </div>
                    </div>
                        <div class="checkbox">
                            <input type="checkbox" id="declaration" value="true" checked />I declare that the above information given is accurate<br />
                        </div>
                        <input class="btn btn-success" type="submit" id="submitNewEntry" runat="server" onclick="NewAssistReg(); false;" value="Submit" />
                </div>

            </div>

            <div class="tab-pane" id="formManagement">
                <p>
                    <br />
                    <br />
                    <br />
                    <br />
                    <br />
                    <br />
                    <br />
                    <br />
                    <br />
                    <br />
                    <br />
                    <br />
                    isadosdoasjdakdadsdasjadslsdk
                </p>
            </div>

            <div class="tab-pane" id="userManagement">
                <br />
                <br />
                <br />
                <br />
                <br />
                <br />
                <br />
                <br />
                <br />
                <br />
                <br />
                <br />
                <p>oiafosdoiadsoadsij</p>
            </div>
        </div>

    </div>
    <script type="text/javascript" src="<%= Page.ResolveClientUrl("~/Scripts/fieldValidations.js") %>"></script>
    <script type="text/javascript">


        $('#navigatePage a:first').tab('show');
        $('#regPageNavigation a:first').tab('show');
        nric.value.toString();

        function purposePanels() {
            var purpose = $("#pInput").val();
            if(purpose === "patient"){
                $("#patientpurposevisit").css("display", "block");
                $("#otherpurposevisit").css("display", "none");
            } else if (purpose === "other") {
                $("#patientpurposevisit").css("display", "none");
                $("#otherpurposevisit").css("display", "block");
            } else {
                $("#patientpurposevisit").css("display", "none");
                $("#otherpurposevisit").css("display", "none");            
            }
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
            $("#nricWarning").css("display", "none");
            $("#patientpurposevisit").css("display", "none");
            $("#otherpurposevisit").css("display", "none");
        }


    </script>

    <script type="text/javascript" src="<%= Page.ResolveClientUrl("~/Scripts/registrationPageScripts.js") %>"></script>
</body>
</html>
