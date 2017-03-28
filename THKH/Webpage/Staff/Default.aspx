<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Default.aspx.cs" Inherits="THKH.Webpage.Staff.Default" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
    <meta charset="utf-8" />
    <title>Welcome <%= Session["username"].ToString()%> | Ang Mo Kio - Thye Hwa Kuan</title>
    <link href="~/Content/bootstrap.min.css" rel="stylesheet" />
    <link rel="stylesheet" href="~/CSS/font-awesome.css" />
    <script type="text/javascript" src="<%= Page.ResolveClientUrl("~/Scripts/html2canvas.js") %>"></script>
    <script type="text/javascript" src="<%= Page.ResolveClientUrl("~/Scripts/jquery-3.1.1.min.js") %>"></script>
    <script type="text/javascript" src="<%= Page.ResolveClientUrl("~/Scripts/moment.min.js") %>"></script>
    <script type="text/javascript" src="<%= Page.ResolveClientUrl("~/Scripts/jquery-ui.min.js") %>"></script>
<%--    <script type="text/javascript" src="<%= Page.ResolveClientUrl("/Scripts/jquery-1.12.4.js") %>"></script>--%>
    <script type="text/javascript" src="<%= Page.ResolveClientUrl("~/Scripts/w3data.js") %>"></script>
    <script type="text/javascript" src="<%= Page.ResolveClientUrl("~/Scripts/bootstrap.min.js") %>"></script>
    <script type="text/javascript" src="<%= Page.ResolveClientUrl("~/Scripts/bootstrap-datetimepicker.js") %>"></script>
    <script type="text/javascript" src="<%= Page.ResolveClientUrl("~/Scripts/dependencies/rsvp-3.1.0.min.js") %>"></script>
    <script type="text/javascript" src="<%= Page.ResolveClientUrl("~/Scripts/dependencies/sha-256.min.js") %>"></script>
    <script type="text/javascript" src="<%= Page.ResolveClientUrl("~/Scripts/canvasjs.min.js") %>"></script>
    <link href="~/CSS/default.css" rel="stylesheet" />
    <link href="~/CSS/adminTerminal.css" rel="stylesheet" />
    <link href="~/CSS/formManagement.css" rel="stylesheet" />
    <link href="~/CSS/passManagement.css" rel="stylesheet" />
    <link rel="stylesheet" type="text/css" 	href="~/CSS/jquery-ui.css"/>
    <link href="~/CSS/jquery.dataTables.min.css" rel="stylesheet" />
    <link href="~/CSS/buttons.dataTables.min.css" rel="stylesheet" />
    <link rel="stylesheet" href="~/CSS/kc.fab.css" />


</head>
<body onload="">
    <% var accessRightsStr = Session["accessRights"].ToString(); %>
    <script type="text/javascript">
        $(function () {


            $(document).ready(function () {// once ready then we toggle based on ajax calls
                $("#loadingGif").toggle(false);
               
                $(document).ajaxStart(function () {
                    $("#loadingGif").toggle(true);
                });
                //or...
                $(document).ajaxComplete(function () {
                    $("#loadingGif").toggle(false);
                });
            });
        });

        // Show Settings Modal
        function showSettingsModal() {
            populateSettingsTime();
            loadPermissionSettingsField();
            getCurrentConfig();
            $("#tempSetWarning").css("display", "none");
            $("#timeSetWarning").css("display", "none");
            $("#tempRangeWarning").css("display", "none");
            $("#timeHighLowWarning").css("display", "none");
            $("#tempHighLowWarning").css("display", "none");
            $('#tempHighWarnWarning').css("display", "none");
            $("#tempLowWarnWarning").css("display", "none");
            $('#settingsModal').modal({ backdrop: 'static', keyboard: false });
            $('#settingsModal').modal('show');
        }

        // Hide Settings Modal
        function hideSettingsModal() {
            $('#settingsModal').modal('hide');
        }

    </script>
     <!-- Loading Gif Here -->
     <div id="loadingGif" style="width:100%;height:100%;background-color:black;opacity:0.5;position: absolute;top: 0;left: 0;z-index: 10000;">
        <img src="../../Assets/cube.svg" style="position: absolute;left: calc(50% - 99px);top: calc(50% - 99px);"/>

    </div>
    <%if (accessRightsStr.Contains('4'))
        { %>
    <div class="modal fade" id="settingsModal" tabindex="-1" role="dialog" aria-labelledby="memberModalLabel" aria-hidden="true">
                    <div class="modal-dialog">
                        <div class="modal-content">
                            <div class="modal-header">
                                <img src="../../Assets/hospitalLogo.png" class="img img-responsive" /><br />
                                <h4 class="modal-title">Master Configuration</h4>
                            </div>
                            <div class="modal-body text-center" id="appSettings">
                                <div class="row">
                                <div class="col-sm-6">
                                <label>Temperature Control</label>
                                <div class="form-group">
                                    <div class="input-group">
                                          <span class="input-group-addon">Lower Limit</span>
                                    <input type="text" class="form-control setInput" id="temSetInputLow" />
                                        </div>
                                    <div class="input-group">
                                          <span class="input-group-addon">Upper Limit</span>
                                    <input type="text" class="form-control setInput" id="temSetInputHigh" />
                                        </div>
                                    <div class="input-group">
                                          <span class="input-group-addon">Warning Temperature</span>
                                    <input type="text" class="form-control setInput" id="temSetInputWarn" />
                                        </div>
                                    <label id="tempHighLowWarning" style="color: lightcoral">Upper limit is higher than the lower limit!</label>
                                    <label id="tempSetWarning" style="color: lightcoral">Please enter the temperature values in this format: "36.7"</label>
                                    <label id="tempRangeWarning" style="color: lightcoral">Please enter a temperature within 34 to 40 degs</label>
                                    <label id="tempHighWarnWarning" style="color: lightcoral">Warning Temperature is above the Upper Limit!</label>
                                    <label id="tempLowWarnWarning" style="color: lightcoral">Warning Temperature is below the Lower Limit!</label>
                                </div>
                                </div>
                                <div class="col-sm-6">
                                <label>Visit Time Control</label>
                                <div class="form-group">
                                    <div class="input-group">
                                          <span class="input-group-addon">Start</span>
                                            <select class="form-control setInput" id="visTimeSetInputLower">
                                                <option value="">-- Select One --</option>
                                            </select>
                                        </div>
                                    <div class="input-group">
                                          <span class="input-group-addon">End</span>
                                            <select class="form-control setInput" id="visTimeSetInputHigh">
                                                <option value="">-- Select One --</option>
                                            </select>
                                        </div>
                                    <label id="timeHighLowWarning" style="color: lightcoral">End Time is before the Start Time!</label>
                                    <label id="timeSetWarning" style="color: lightcoral">Please provide a visit time range</label>
                                </div>
                                    
                                </div>
                                    </div>
                                <div class="row">
                                    <div class="col-sm-6">
                                    <label>Visitor Limit/Bed</label>
                                    <div class="form-group">
                                    <div class="input-group">
                                        <span class="input-group-addon">Limit</span>
                                            <input type="text" class="form-control setInput" placeholder="Please enter a numerical value" id="visLimInput" />
                                    </div>
                                </div>
                                        </div>
                                </div>
                                <div class="row">
                                <button class="btn btn-success" id="saveSettingsButton" onclick="updateConfig(); false;"><span class="glyphicon glyphicon-floppy-saved"></span> Save Settings</button>
                                    </div>
                                <div class="modal-body text-center">
                                    <div class="row">
                                <label>Access Profile Control</label>
                                <div class="form-group">
                                    <div class="input-group">
                                          <span class="input-group-addon">Profile</span>
                                            <select class="form-control setInput profDrop" onchange="getSelectedAccessProfile(); false;" id="permissionProfile">
                                                <option value="">-- Select One --</option>
                                            </select>
                                        <span class="input-group-btn">
                                <button class="btn btn-primary" id="newProfileButton" onclick="showNewProfileModal(); false"><span class="glyphicon glyphicon-plus"></span> New Profile</button>
                                <button class="btn btn-warning" id="delProfileButton" onclick="showDelProfileModal(); false;"><span class="glyphicon glyphicon-trash"></span> Delete Profile</button>
                            </span>
                                        </div>
                                    </div>
                                <div id="permissSet" class="form-group">
                                <%--checkbox--%>
                                </div>
                                <button id="savePermissGroup" class="btn btn-success" onclick="updateAccessProfile(); false;"><span class="glyphicon glyphicon-floppy-saved"></span> Save Access Profile</button>
                                    </div>
                                </div>
                                <div class="modal-footer">
                                    <button class="btn btn-danger btn-block" id="closeSettingsButton" onclick="hideSettingsModal(); false;"><span class="glyphicon glyphicon-remove"></span> Close</button>     
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="modal fade" id="newProfileModal" tabindex="-1" role="dialog" aria-labelledby="memberModalLabel" aria-hidden="true">
                    <div class="modal-dialog">
                        <div class="modal-content">
                            <div class="modal-header">
                                <img src="../../Assets/hospitalLogo.png" class="img img-responsive" /><br />
                                <h4 class="modal-title">Master Configuration</h4>
                            </div>
                            <div class="modal-body text-center" id="newProfileDiv">
                                <div class="row">
                                <label>New Access Control Profile</label>
                                <div class="form-group">
                                    <div class="input-group">
                                          <span class="input-group-addon">Profile Name</span>
                                    <input type="text" class="form-control required" placeholder="Please enter a unique profile name/role" id="newProfNameInput" />
                                        </div>
                                </div>
                                    </div>
                                <div class="modal-footer">
                                    <button class="btn btn-danger" id="closeNewProfileButton" onclick="hideNewProfileModal(); false;"><span class="glyphicon glyphicon-remove"></span> Cancel</button>     
                                    <button class="btn btn-success" id="saveProfileButton" onclick="newAccessProfile(); false;"><span class="glyphicon glyphicon-floppy-saved"></span> Save Profile</button>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="modal fade" id="delProfileModal" tabindex="-1" role="dialog" aria-labelledby="memberModalLabel" aria-hidden="true">
                    <div class="modal-dialog">
                        <div class="modal-content">
                            <div class="modal-header">
                                <img src="../../Assets/hospitalLogo.png" class="img img-responsive" /><br />
                                <h4 class="modal-title">Delete Profile</h4>
                                <label style="color:lightcoral">Do you wish to delete this user access control profile? Changes cannot be undone.</label>
                                <button class="btn btn-danger" id="closeDelProfileButton" onclick="hideDelProfileModal(); false;"><span class="glyphicon glyphicon-remove"></span> Cancel</button>     
                                    <button class="btn btn-success" id="delSelProfileButton" onclick="delAccessProfile(); false;"><span class="glyphicon glyphicon-trash"></span> Delete Profile</button>
                            </div>
                            </div>
                    </div>
                </div>
    <% } %>
    <nav id="mainNav" class="navbar navbar-default navbar-fixed-top">
        <div class="container-fluid">
            <div class="navbar-header">
                <button type="button" class="navbar-toggle collapsed" data-toggle="collapse" data-target="#navbar-main">
                    <span class="icon-bar"></span>
                    <span class="icon-bar"></span>
                    <span class="icon-bar"></span>
                </button>
                <a class="navbar-brand"><b>Thye Hua Kwan Hospital</b></a>
            </div>
            <div class="collapse navbar-collapse" id="navbar-main">
                <ul class="nav navbar-nav " id="navigatePage">
                    <%if (accessRightsStr.Contains('1'))
                        { %>
                    <li id="regtab" runat="server">
                        <a href="#registration" data-toggle="tab" onclick="hideTags(true); false;">Registration
                        </a>
                    </li>
                    <%  }
                        if (accessRightsStr.Contains('2'))
                        {%>
                    <li>
                        <a href="#formManagement" data-toggle="tab" onclick="loadFormManagementOnce()">Form Management
                        </a>
                    </li>
                    <%  }
                        if (accessRightsStr.Contains('3'))
                        {%>
                    <li>
                        <a href="#TerminalManagement" data-toggle="tab" onclick="loadTerminals()">Terminals Management
                        </a>
                    </li>
                    <%  }
                        if (accessRightsStr.Contains('4'))
                        {%>
                    <li>
                        <a href="#UserManagement" data-toggle="tab" onclick="loadUsersOnce()">User Management
                        </a>
                    </li>
                    <%  }
                        if (accessRightsStr.Contains('5'))
                        {%>
                    <li>
                        <a href="#PassManagement" data-toggle="tab" onclick="loadPassState()">Pass Management
                        </a>
                    </li>
                    <%  }
                    if (accessRightsStr.Contains('6'))
                    {%>
                    <li>
                        <a href="#ContactTracing" data-toggle="tab">Contact Tracing
                        </a>
                    </li>
                    <li>
                        <a href="#Dashboard" data-toggle="tab">Visualization
                        </a>
                    </li>
                    <li>
                        <a href="#SMS" data-toggle="tab">SMS
                        </a>
                    </li>
                    <%  }
                    if (accessRightsStr.Contains('4'))
                    {%>
                    <li>
                        <a href="#" onclick="showSettingsModal(); false;">Configurations
                        </a>
                    </li>
                    <%  }%>
                </ul>
                        <form id="logbtn" class="nav navbar-nav navbar-right" style="margin-top: 10px;" runat="server">
                            <div>
                                <label>Welcome, <%= Session["username"].ToString()%></label>
                                <asp:Button ID="logout" class="btn btn-danger" Text="Logout" OnClick="logout_Click" runat="server" />
                            </div>
                        </form>
            </div>
        </div>
    </nav>

    <div id="main" class="container containerMain">
        <div class="tab-content tab-content-main maxHeight" style="border: 0;" id="generalContent">
            <!-- Registration -->
            <%if (accessRightsStr.Contains('1'))
                { %>
            <div class="tab-pane maxHeight" id="registration">
                <div class="kc_fab_wrapper"></div>
                <a data-controls-modal="successModal" data-backdrop="static" data-keyboard="false" href="#/"></a>
                <div class="modal fade" id="successModal" tabindex="-1" role="dialog" aria-labelledby="memberModalLabel" aria-hidden="true">
                    <div class="modal-dialog">
                        <div class="modal-content">
                            <div class="modal-header text-center">
                                <img src="../../Assets/hospitalLogo.png" class="img img-responsive" /><br />
                                <h4 class="modal-title" id="memberModalLabel1">Registration Successful</h4>
                            </div>
                            <div class="modal-body text-center" id="userSuccess">
                                    <label>Visit data recorded at <%=TimeZone.CurrentTimeZone.ToUniversalTime(DateTime.Now).AddHours(8).ToString() %>.</label>
                                    <label>Visitor has been checked in!</label>
                            </div>
                            <div class="modal-footer">
                                <button class="btn btn-block btn-info" id="printButton" onclick="printPass(); false;"><span class="glyphicon glyphicon-list-alt"></span> Print</button>
                                <button class="btn btn-block btn-danger" id="closeSuccessButton" onclick="hideSuccessModal(); false;"><span class="glyphicon glyphicon-remove"></span> Close</button>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="modal fade" id="maxLimitModal" tabindex="-1" role="dialog" aria-labelledby="memberModalLabel" aria-hidden="true">
                    <div class="modal-dialog">
                        <div class="modal-content">
                            <div class="modal-header text-center">
                                <img src="../../Assets/hospitalLogo.png" class="img img-responsive" /><br />
                                <h4 class="modal-title" id="memberModalLabel2" style="color:darkred">Warning</h4>
                            </div>
                            <div class="modal-body text-center">
                                    <label>Visitor Limit for this Bed has been Reached!</label>
                            </div>
                            <div class="modal-footer">
                                <button class="btn btn-block btn-danger" id="closeMaxLimitButton" onclick="hideMaxLimitModal(); false;"><span class="glyphicon glyphicon-remove"></span> Close</button>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="row">
                    <div id="nurseInputArea" class="col-md-6 col-md-offset-3">
                        <div class="jumbotron" style="text-align: left">
                            <h3 style="color:lightblue">Search for Visitor</h3>
                            <label class="control-label" for="nric"><span style="color:lightcoral">*</span>Visitor's NRIC:</label>
                            <div class="input-group date" id="nricinputgroup">
                                <span class="input-group-btn">
                                    <button class="btn btn-default" id="clearAllBtn" onclick="hideTags(true); false;"><span class="glyphicon glyphicon-ban-circle"></span> Clear Fields</button>  
                                </span>
                                <input id="nric" class="form-control required regInput" type="text" autofocus="autofocus" />       
                            </div>
                            <h4 id="emptyNricWarning" style="color: lightcoral">Please enter an NRIC/Identification Number!</h4>
                            <div id="nricWarnDiv">
                                <h4 id="nricWarning" style="color: lightcoral">Non-Singapore Based NRIC/ID!</h4>
                                <div class="checkbox">
                                    <label for="ignoreNric"></label>
                                    <input type="checkbox" id="ignoreNric" name="declare" value="true" class="regInput" />Allow Anyway<br />
                                    <label for="ignoreNric" id="ignoreNricLbl" style="color: lightcoral">Please check this option to continue</label>
                                </div>
                            </div>
                            <div id="ambulanceDiv">
                                <div class="checkbox">
                                    <label for="ambulCheck"></label>
                                    <input type="checkbox" id="ambulCheck" name="declare" value="true" class="regInput" />Express Entry<br />
                                </div>
                            </div>
                            <br />
                            <label class="control-label" id="tempLbl" for="temp"><span style="color:lightcoral">*</span>Temperature</label>
                            <input id="temp" onkeypress=" return enterToCheckNric(event)" class="form-control required regInput" type="text" />
                            <h4 id="tempWarning" style="color: lightcoral">Warning! Fever!</h4>
                            <h4 id="tempLimitWarning" style="color: lightcoral">Invalid Temperature</h4>
                            <h4 id="lowtempWarning" style="color: lightcoral">Invalid Temperature</h4>
                            <h4 id="invalidTempWarning" style="color: lightcoral">Please enter a valid temperature in the following format: "36.7"</h4>
                            <div id="remarksExpressDiv">
                                <h3 style="color:lightblue">Additional Information</h3>
                                <label for="remarksExpressInput"><span style="color:lightcoral">*</span>Remarks</label>
                                <div class="form-group">
                                    <textarea id="remarksExpressInput" class="form-control regInput" rows="2" placeholder="Please enter the reason for express entry, contact & vehicle number" cols="60"></textarea>
                                <%--<input type="text" class="form-control regInput" id="remarksExpressInput" placeholder="Please enter the reason for express entry, contact & vehicle number"/>--%>
                            </div>
                            </div>
                            <button class="btn btn-warning" id="checkNricButton" onclick="checkNricWarningDeclaration(); false;"><span class="glyphicon glyphicon-search"></span> Proceed</button>
                        </div>
                    </div>
                </div>

                <div class="row" id="userData">
                    <div id="newusercontent" class="col-sm-6">
                        <div class="jumbotron" style="text-align: left">
                            <h3 style="color:lightblue">Personal Details</h3>
                            <label for="namesinput"><span style="color:lightcoral">*</span>Full Name</label>
                            <div class="form-group">
                                <input type="text" class="form-control required regInput" id="namesInput" />
                            </div>
                            <label for="mobileinput"><span style="color:lightcoral">*</span>Contact Number</label>
                            <div class="form-group">
                                <input type="text" class="form-control required regInput" id="mobilesInput" />
                                <label for="mobilesInput" id="mobWarning" style="color: lightcoral">Invalid Phone Number Format!</label>
                            </div>
                            <label for="sexinput"><span style="color:lightcoral">*</span>Gender</label>
                            <div class="form-group">
                                <select class="form-control required" id="sexinput">
                                    <option value="">-- Select One --</option>
                                    <option value="M">Male</option>
                                    <option value="F">Female</option>
                                </select>
                                <label for="sexinput" id="sexWarning" style="color: lightcoral">Please select a gender!</label>
                            </div>
                            <label for="nationalinput"><span style="color:lightcoral">*</span>Country (Nationality)</label>
                            <div class="form-group">
                                <select class="form-control required regInput" onchange="checkNationals(); false;" id="nationalsInput">
                                    <option value="">-- Select One --</option>
                                </select>
                                <label for="nationalsInput" id="natWarning" style="color: lightcoral">Please select a nationality!</label>
                            </div>
                            <label for="daterange"><span style="color:lightcoral">*</span>Date of Birth (DD-MM-YYYY)</label>
                            <div class="form-group">
                                <div class="input-group date" id="datetimepicker">
                                    <input type='text' id="daterange" class="form-control required regInput" />
                                    <span class="input-group-addon">
                                        <span class="glyphicon glyphicon-calendar"></span>
                                    </span>
                                </div>
                            </div>
                            <label id="dateWarning" style="color: lightcoral">Invalid Date Format!</label>
                            <label for="addressinput"><span style="color:lightcoral">*</span>Address</label>
                            <div class="form-group">
                                <input type="text" class="form-control required regInput" id="addresssInput" />
                            </div>
                            <label for="postalinput"><span style="color:lightcoral">*</span>Postal Code</label>
                            <div class="form-group">
                                <input type="text" class="form-control required regInput" id="postalsInput" />
                                <label for="postalsInput" id="posWarning" style="color: lightcoral">Invalid Postal Code Format!</label>
                            </div>
                        </div>
                    </div>
                    <div id="staticinfocontainer" class="col-sm-6" style="text-align: left">
                        <div class="jumbotron" style="text-align: left">
                            <h3 style="color:lightblue">Visit Details</h3>
                            <label for="pInput"><span style="color:lightcoral">*</span>Visit Purpose</label>
                            <%--Check for Purpose of Visit--%>
                            <div class="form-group">
                                <select class="form-control required regInput" id="pInput" onchange="purposePanels()" name="pInput">
                                    <option value="">-- Select One --</option>
                                    <option value="Visit Patient">Visit Patient</option>
                                    <option value="Other Purpose">Other Purpose</option>
                                </select>
                                <label for="pInput" id="purWarning" style="color: lightcoral">Please select a Visit Purpose!</label>
                            </div>
                            <div id="patientpurposevisit" class="container-fluid">
                                <%--Show this only when Visit Purpose is "Visit Patient"--%>
                                <label for="patientName"><span style="color:lightcoral">*</span>Patient Name</label>
                                <div class="form-group">
                                    <input autocomplete="off" type="text" class="form-control regInput" onkeyup="nameSearch(this);" id="patientName" />
                                </div>
                                <div id="searchResultsDiv" class="searchbox"></div>
                                <label for="bedno"><span style="color:lightcoral">*</span>Bed Number</label>
                                <%--Bed Number--%>
                                <div class="form-group">
                                    <input type="text" class="form-control regInput"  onkeyup="bedSearch(this);" id="bedno" />
                                </div>
                                <input type="hidden" class="form-control regInput" id="patientNric" />
                                <label></label>
                                <div class="form-group">
                                    <button id="validatePatientButton" value="Validate Patient Information" class="btn btn-warning" onclick="validatePatient(); false;"><span class="glyphicon glyphicon-ok-circle"></span>Add Patient</button>
                                    <label id="patientStatusGreen" style="color: green">Patient Found!</label>
                                    <label id="patientStatusRed" style="color: lightcoral">Patient Not Found!</label>
                                </div>
                                

                                <label>Beds To Be Visited</label>
                                <div id="bedsAdded" class="col-xs-12 bedNoDisplay required">

                                </div>
                            </div>
                            <div id="otherpurposevisit" class="container-fluid">
                                <%--Show this only when Visit Purpose is "Other Purpose"--%>
                                <label for="visLoc"><span style="color:lightcoral">*</span>Intended Visit Location</label>
                                <div class="form-group">
                                    <select class="form-control" id="visLoc">
                                        <option value="">-- Select One --</option>
                                    </select>
                                </div>
                                <label for="purposeInput"><span style="color:lightcoral">*</span>Purpose of Visit</label>
                                <div class="form-group">
                                    <input type="text" class="form-control regInput" id="purposeInput" />
                                </div>
                            </div>
                            <%--Visit Date--%>
                            <label for="visitbookingdate"><span style="color:lightcoral">*</span>Intended Visit Date (DD-MM-YYYY)</label>
                            <div class="input-group date" id="visitbookingdatediv">
                                <input type='text' id="visitbookingdate" class="form-control required regInput excludeClear" disabled />
                                <span class="input-group-addon">
                                    <span class="glyphicon glyphicon-calendar"></span>
                                </span>
                            </div>
                            <%--Visit Time--%>
                            <label for="visitbookingtime"><span style="color:lightcoral">*</span>Intended Visit Time (HH:mm)</label>
                            <div class="form-group">
                                <select class="form-control required regInput" onchange="checkTime(); false;" id="visitbookingtime">
                                        <option value="">-- Select One --</option>
                                    </select>
                                 <label for="declaration" id="timelabel" style="color: lightcoral">Please choose a Visit Time!</label>
                            </div>
                            <h3 style="color:lightblue">Health Screening Form</h3>
                            <div id="questionaireForm">
                                <!-- load questionaires here from JS -->
                            </div>
                            <div id="remarksDiv">
                                <h3 style="color:lightblue">Additional Information</h3>
                                <label for="remarksinput">Remarks</label>
                                <div class="form-group">
                                <input type="text" class="form-control regInput" id="remarksinput" />
                            </div>
                            </div>
                            <input type="hidden" class="form-control regInput" id="qaid" />
                            <h4 id="emptyFields" style="color: lightcoral">Please fill in all the required fields with valid data (*) highlighted in yellow & rectify the fields with warning(s) shown.</h4>
                            <button class="btn btn-success btn-block" id="submitNewEntry" onclick="checkRequiredFields(); false;"><span class="glyphicon glyphicon-list-alt"></span> Submit</button>
                        </div>
                    </div>
                </div>
            </div>
            <!-- End of Registration -->
            <%}
                if (accessRightsStr.Contains('2'))
                { %>
            <!-- FormManagement -->
            <div class="tab-pane maxHeight " id="formManagement">
                <div class="row inheritHeight">
                    <!-- questionaire portion -->
                    <div class="col-sm-6 panel"  style="height: 100%;margin-bottom:0">
                        <div class="modal fade" id="addQuestionnaire" role="dialog">
                            <div class="modal-dialog">
                                <div class="modal-content">
                                    <div class="modal-header" style="padding: 0px 50px; text-align: center;">
                                        <img src="../../Assets/hospitalLogo.png" class="img img-responsive" /><br />
                                        <h4>Add New Form</h4>
                                    </div>
                                    <div class="modal-body" style="padding: 40px 50px; text-align: center;">
                                        <div class="input-group">
                                          <span class="input-group-addon" id="basic-addon">Form Name</span>
                                          <input type="text" class="form-control" id="qnaireid" aria-describedby="basic-addon" />      
                                        </div>
                                        <label id="emptyQuestionnaireWarning" style="color:red">Please enter a form name!</label>
                                            <label id="questionnaireWarning" style="color:red">Form name already exists! Please use a unique name.</label><br />
                                        <button type="submit" class="btn btn-danger btn-default" onclick="hideAddQuestionnaireModal();"><span class="glyphicon glyphicon-remove"></span> Cancel</button>
                                    <button type="button" class="btn btn-success" onclick="newQuestionnaire();"><span class="glyphicon glyphicon-plus"></span> Add Form</button>
                                        </div>
                                   <%-- <div class="modal-footer" style="text-align: center !important;">
                                        
                                    </div>--%>
                                </div>
                            </div>
                        </div>
                        <h3 style="">Select a Form to Begin</h3>
                        <h5 style="font-style:italic">Please remember to save your form</h5>
                        <div class="input-group" id="qnaireSelection">
                            <select class="form-control qnaire" id="qnaires" onchange="displayQuestionnaireQuestions(); false;">
                                <option value="">-- No Forms Created --</option>

                            </select>
                            <span class="input-group-btn">
                                <button class="btn btn-primary" id="addQuestionnaireButton" onclick="showAddQuestionnaireModal();"><span class="glyphicon glyphicon-plus"></span> New Form</button>
                                <button class="btn btn-success" id="activeQuestionnaireButton" onclick="setActiveQuestionnaire(); false;"><span class="glyphicon glyphicon-star"></span> Set Active</button>
                            </span>
                        </div>
                        <div class="list-group" style="overflow: auto; height: 70%; border: solid 1pt; border-radius: 2px; margin-top: 3px;" id="questionnaireQuestionsToDisplay">
                            <%--Draggable Questions--%>
                            <ul class="list-group checked-list-box qnQns" id="sortable">
                            </ul>
                        </div>
                        <div class="btn-group">
                            <button type="button" onclick="selectAll('qnaire'); false;" class="btn btn-default"><span class="glyphicon glyphicon-check"></span> Select All</button>
                            <button type="button" onclick="deSelectAll('qnaire');false;" class="btn btn-default"><span class="glyphicon glyphicon-unchecked"></span> Deselect All</button>
                        </div>
                        <br />
                        <div class="btn-group">
                            <button type="button" id="delQuestionsFromQuestionnaire" onclick="removeQFromQuestionnaire(); false;" class="btn btn-danger"><span class="glyphicon glyphicon-trash"></span> Remove Questions</button>
                            <button type="submit" id="saveQuestionnaireChangesButton" onclick="updateQuestionnaire(); false;" class="btn btn-success"><span class="glyphicon glyphicon-floppy-saved"></span> Save Form</button>
                        </div>
                        <div class="modal fade" id="updateQuestionnaireSuccess" role="dialog">
                                    <div class="modal-dialog">

                                        <!-- Modal content-->
                                        <div class="modal-content">
                                            <div class="modal-header" style="padding: 0px 50px; text-align: center;">
                                                <img src="../../Assets/hospitalLogo.png" class="img img-responsive" /><br />
                                                <h4>Form Saved!</h4>

                                            </div>
                                            <div class="modal-body" style="text-align: center;">
                                                <%--<label>Form Saved!</label>--%>
                                                <button type="button" id="closeUpdateQuestionnaire" onclick="closeUpdateSuccess(); false;" class="btn btn-danger"><span class="glyphicon glyphicon-remove"></span>Close</button>
                                            </div>
                                            <%--<div class="modal-footer" style="text-align: center !important;">
                                                
                                            </div>--%>
                                        </div>

                                    </div>
                                </div>
                        <div class="modal fade" id="setActiveSuccess" role="dialog">
                                    <div class="modal-dialog">

                                        <!-- Modal content-->
                                        <div class="modal-content">
                                            <div class="modal-header" style="padding: 0px 50px; text-align: center;">
                                                <img src="../../Assets/hospitalLogo.png" class="img img-responsive" /><br />
                                                <h4>Form Activated!</h4>
                                            </div>
                                            <div class="modal-body" style="text-align: center;">
                                                <%--<label>Form set as Active!</label>--%>
                                                <button type="button" id="closeActiveSuccess" onclick="closeActiveSuccess(); false;" class="btn btn-danger"><span class="glyphicon glyphicon-remove"></span>Close</button>
                                            </div>
                                            <%--<div class="modal-footer" style="text-align: center !important;">
                                                
                                            </div>--%>
                                        </div>

                                    </div>
                                </div>
                        <div class="modal fade" id="addQuestionnaireSuccess" role="dialog">
                                    <div class="modal-dialog">

                                        <!-- Modal content-->
                                        <div class="modal-content">
                                            <div class="modal-header" style="padding: 0px 50px; text-align: center;">
                                                <img src="../../Assets/hospitalLogo.png" class="img img-responsive" /><br />
                                                <h4>Form Added!</h4>

                                            </div>
                                            <div class="modal-body" style="text-align: center;">
                                                <%--<label>Form Added!</label>--%>
                                                <button type="button" id="closeAddQuestionnaireSuccess" onclick="closeAddQuestionnaireSuccess(); false;" class="btn btn-danger"><span class="glyphicon glyphicon-remove"></span>Close</button>
                                            </div>
                                            <%--<div class="modal-footer" style="text-align: center !important;">
                                                
                                            </div>--%>
                                        </div>

                                    </div>
                                </div>
                    </div>

                    <!-- questions to be added portion -->
                    <div class="col-sm-6 panel" style="height: 100%;margin-bottom:0">
                        <div class="list-group" style="height: 94%;" id="questionnaireQuestions">
                            <h3 style="">Available Question(s)</h3>
                            <h5 style="font-style:italic">Check questions to add it to the form</h5>
                            <%--Checkbox Questions--%>
                            <div class="input-group" id="searchQns">
                                <input type="text" class="form-control maxWidth" id="searchQ" placeholder="Enter term to search in question list..." onkeyup="filterCurrentList(this)" />
                                <span class="input-group-btn">
                                    <button type="button" id="createNewQuestion" onclick="toggleQnEditor(); false;" class="btn btn-success"><span class="glyphicon glyphicon-plus"></span> New Question</button>
                                </span>
                            </div>
                            <div class=" " style="border: solid 1pt; border-radius: 2px; height: 75%; overflow-y: auto; margin-top: 2px;">

                                <div id="cover" style="width: 100%; height: inherit; padding-right: 30px; position: absolute; display: none">
                                    <div style="background-color: grey; opacity: 0.5; position: absolute; width: calc(100% - 30px); height: calc(100% - 30px);"></div>
                                </div>
                                <ul class="list-group checked-list-box maxHeight" id="allQuestions" style="">
                                </ul>
                                <div id="qnEditor" class="panel-collapse collapse placeAboveOtherDivs" style="margin-top: 0; width: 100%; padding-right: 32px;position: absolute;top: 97px;">
                                    <div class="panel-body questionEditor" style="background-color: #343637; border-style: solid; border-width: 1px;">
                                        <h3 id="editQuestionTitle">Question Details</h3>
                                        <div>Question<textarea id="detailsQn" class="form-control qnVal" rows="3" cols="80">  </textarea></div>
                                        <div>
                                            Question Response Type
                                            <select id="detailsQnType" onchange="checkAnsType(); false;" class="form-control qnVal">
                                                <option value="" selected="selected">-- Select a type --</option>
                                                <option value="ddList">Drop-down list</option>
                                                <option value="checkbox">Checkbox</option>
                                                <option value="radio">Radio Button</option>
                                                <option value="text">Text Field</option>
                                            </select>
                                        </div>
                                        <div>
                                            Question Values
                                            <textarea id="detailsQnValues" class="form-control qnVal" rows="2" placeholder="Enter answer values seperated by comma in the following format: <Option 1>,<Option 2>,<Option 3>" cols="60"></textarea>
                                        </div><br />
                                        <button type="button" data-toggle="collapse" data-target="#qnEditor" id="closeQnEditor" onclick="closeEditor(); false;" class="btn btn-danger"><span class="glyphicon glyphicon-remove"></span> Close</button>
                                        <button type="button" id="updateOrCreateQn" onclick="updateOrCreate(); false;" class="btn btn-success"><span class="glyphicon glyphicon-floppy-saved"></span> Save Question</button>
                                        <label id="emptyQuestionWarning" style="color:red">Please enter a question/answer type!</label>
                                        <label id="questionWarning" style="color:red">Question name already exists! Please use a unique name.</label>
                                        <label id="questionValWarning" style="color:red">Question type requires a response value! Please enter at least 1 response value.</label>
                                    </div>
                                </div>
                            </div>

                            <div class="btn-group">
                                <button type="button" id="selectAll" onclick="selectAll('qns'); false;" class="btn btn-warning"><span class="glyphicon glyphicon-check"></span>Select All</button>
                                <button type="button" id="deSelectAll" onclick="deSelectAll('qns');false;" class="btn btn-warning"><span class="glyphicon glyphicon-unchecked"></span>Unselect All</button>
                            </div>
                            <br />
                            <div class="btn-group">
                                <button type="button" id="addQuestionsToQuestionnaire" onclick="AddQtoQuestionnaire(); false;" class="btn btn-success"><span class="glyphicon glyphicon-plus"></span> Add to Form</button>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
            <%}
                if (accessRightsStr.Contains('3'))
                { %>
            <!-- End of FormManagement -->

            <!-- TerminalManagement -->
            <div class="tab-pane maxHeight " style="position: relative" id="TerminalManagement">
                <div class="row inheritHeight">
                    <div class="col-md-8 col-md-offset-2 inheritHeight flexDisplay">
                        <div class="panel  panel-primary maxWidth  removeBtmMargin">
                            <div class="panel-heading" style="font-size: 36px;">Terminals</div>
                            <div class="panel-body " style="height:calc(100% - 140px)">

                                <div class="modal fade" id="addTerminalModal" role="dialog">
                                    <div class="modal-dialog">

                                        <!-- Modal content-->
                                        <div class="modal-content">
                                            <div class="modal-header" style="padding: 0px 50px; text-align: center;">
                                                <img src="../../Assets/hospitalLogo.png" class="img img-responsive" /><br />
                                                <h4>Add New Terminal</h4>
                                            </div>
                                            <div class="modal-body" style="text-align: center;">

                                                <div class="form-group">
                                                    <label>Terminal Name</label>
                                                    <input type="text" class="form-control text-center" id="terminalNameInput" placeholder="Enter Terminal Name" />
                                                     <label>Terminal linked to a bed?</label>
                                                    <select class="form-control" id="terminalBedLink" >
                                                        
                                                        <option value="No">No</option>
                                                        <option value="Yes">Yes</option>
                                                    </select>
                                                    <label>Bed's attached to Terminal</label>
                                                    <input type="text" class="form-control text-center" id="beds" disabled="" placeholder="Enter Bed Numbers seperated by comma" />
                                                    <%--<div class="form-group">--%>
                                                    
                                                    <%--</div>--%>
                                                </div>

                                                

                                            </div>
                                            <div class="modal-footer" style="text-align: center !important;">
                                                <button type="button" id="adminCloseTerminal" class="btn btn-danger "><span class="glyphicon glyphicon-remove"></span> Cancel</button>
                                            <button type="button" class="btn btn-success" id="addNewTerminal"><span class="glyphicon glyphicon-plus"></span> Add New Terminal</button>
                                            </div>
                                        </div>

                                    </div>
                                </div>
                                <div class="modal fade" id="promptTerminalModal" role="dialog">
                                    <div class="modal-dialog">

                                        <!-- Modal content-->
                                        <div class="modal-content">

                                            <div class="modal-body" id="prompText" style="text-align: center;">

                                                <label>Successfully Added New Terminal</label>

                                            </div>
                                            <div class="modal-footer" style="text-align: center !important;">
                                                <button type="button" id="closeAllTerminal" class="btn btn-danger "><span class="glyphicon glyphicon-remove"></span>Close</button>
                                            </div>
                                        </div>

                                    </div>
                                </div>

                                <div class="modal fade" id="genericTerminalModal" role="dialog">
                                    <div class="modal-dialog">

                                        <!-- Modal content-->
                                        <div class="modal-content">

                                            <div class="modal-body" id="GenericMessage" style="text-align: center;">

                                                <!-- message here -->

                                            </div>
                                            <div class="modal-footer" style="text-align: center !important;">
                                                <button type="button" id="confirmAction" class="btn bg-primary btn-default "><span class="glyphicon glyphicon-floppy-saved"></span>Confirm</button>
                                                <button type="button" id="cancelAction" class="btn btn-danger btn-default "><span class="glyphicon glyphicon-remove"></span>Close</button>
                                            </div>
                                        </div>

                                    </div>
                                </div>
                                <!-- Show terminals avail here -->
                                <div id="terminals" class="table-bordered maxHeight overflowXaxis">
                                    <ul class="list-group checked-list-box" id="terminalList">
                                        <!-- auto generated -->
                                    </ul>
                                </div>
                                   <div>
                                <button id="addTerminal" class="btn-primary btn">Add Terminal</button>
                                <button id="deactivateTerminal" class="btn-primary btn">Deactivate Selected Terminal</button>
                                <button id="deleteTerminal" class="btn-primary btn">Delete Selected Terminal</button>

                            </div>
                            <div>
                                <button type="button" id="selectAllTerminals" onclick="selectAllTerminals();" class="btn-primary btn">Select All Terminals</button>
                                <button id="deselectAllTerminals"  onclick="deselectAllTerminals();"" class="btn-primary btn">Deselect All Terminals</button>
                            </div>


                            </div>
                         
                        </div>
                    </div>
                </div>


            </div>
            <%}
                if (accessRightsStr.Contains('4'))
                { %>
            <!-- End of TerminalManagement -->

            <!-- UserManagement -->
            <div class="tab-pane maxHeight" id="UserManagement">
                <div class="modal fade" id="addUserSuccessModal" tabindex="-1" role="dialog" aria-labelledby="memberModalLabel" aria-hidden="true">
                    <div class="modal-dialog">
                        <div class="modal-content">
                            <div class="modal-header text-center">
                                <img src="../../Assets/hospitalLogo.png" class="img img-responsive" /><br />
                                <h4 class="modal-title">User Added Successfully!</h4>
                            </div>
                            <div class="modal-body text-center">
                                    <label>New user added at <%=TimeZone.CurrentTimeZone.ToUniversalTime(DateTime.Now).AddHours(8).ToString() %>.</label>
                            </div>
                            <div class="modal-footer">
                                <button class="btn btn-block btn-danger" onclick="hideAddUserSuccessModal(); false;"><span class="glyphicon glyphicon-remove"></span> Close</button>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="modal fade" id="updateUserSuccessModal" tabindex="-1" role="dialog" aria-labelledby="memberModalLabel" aria-hidden="true">
                    <div class="modal-dialog">
                        <div class="modal-content">
                            <div class="modal-header text-center">
                                <img src="../../Assets/hospitalLogo.png" class="img img-responsive" /><br />
                                <h4 class="modal-title">User Updated Successfully!</h4>
                            </div>
                            <div id="updateUserTextDiv" class="modal-body text-center">
                                    <label>User information updated at <%=TimeZone.CurrentTimeZone.ToUniversalTime(DateTime.Now).AddHours(8).ToString() %>.</label>
                            </div>
                            <div class="modal-footer">
                                <button class="btn btn-block btn-danger" onclick="hideUpdateUserSuccessModal(); false;"><span class="glyphicon glyphicon-off"></span> Close</button>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="row inheritHeight">
                    <div class="col-sm-4 inheritHeight">
                        <h3 style="">Existing Users</h3>
                        <%--<div class="form-group" id="searchUser">
                            <input type="text" class="form-control maxWidth" placeholder="Search Name" onkeyup="filterUserList(this)" />
                        </div>--%>
                        <div class=" " style="border: solid 1pt;margin-bottom: 25px; border-radius: 2px; height: 77%; overflow-y: auto; margin-top: 2px;">
                            <ul class="list-group checked-list-box maxHeight" id="usersLis" style="">
                                <%--List of users here--%>
                            </ul>
                        </div>
                    </div>

                    <div class="col-sm-8 row" id= "userInfo" style="overflow-y: auto">
                        <h2 id="userMode">Create New User</h2>
                        <h3 style="margin-top: 0;margin-bottom: 0;">User details</h3>
                        <div>
                            <div class="col-md-6">
                                <label><span style="color:lightcoral">*</span>Email</label>
                                <div class="form-group">
                                    <input id="staffEmail" class="form-control required userInput" placeholder="<ID>@AMKTHKH.com" />
                                    <h4 id="emailWarningUser" style="color: lightcoral">Invalid Email Format!</h4>
                                </div>
                                <label><span style="color:lightcoral">*</span>First Name</label>
                                <div class="form-group">
                                    <input id="staffFirstName" class="form-control required userInput" /></div>
                                <label><span style="color:lightcoral">*</span>Last Name</label>
                                <div class="form-group">
                                    <input id="staffLastName" class="form-control required userInput" /></div>
                                <label>NRIC</label>
                                <div class="form-group">
                                    <input id="staffNric" class="form-control userInput" />
                                    <h4 id="emptyNricWarningUser" style="color: lightcoral">Please enter an NRIC/Identification Number!</h4>
                                    <h4 id="nricWarningUser" style="color: lightcoral">Non-Singapore Based NRIC/ID!</h4>
                                </div>
                                <label>Address</label>
                                <div class="form-group">
                                    <input id="staffAddress" class="form-control userInput" /></div>
                                <label>Postal Code</label>
                                <div class="form-group">
                                    <input id="staffPostal" class="form-control userInput" />
                                    <label id="posWarningUser" style="color: lightcoral">Invalid Postal Code Format!</label>
                                </div>
                                <label>Contact Number</label>
                                <div class="form-group">
                                    <input id="staffMobileNum" class="form-control userInput" />
                                    <label id="mobWarningUser" style="color: lightcoral">Invalid Phone Number Format!</label>
                                </div>
                                <label>Home Number</label>
                                <div class="form-group">
                                    <input id="staffHomeNum" class="form-control userInput" />
                                    <label id="homWarningUser" style="color: lightcoral">Invalid Phone Number Format!</label>
                                </div>
                                </div>
                            <div class="col-md-6">
                                <label>Alternate Number</label>
                                <div class="form-group">
                                    <input id="staffAltNum" class="form-control userInput" />
                                    <label id="altWarningUser" style="color: lightcoral">Invalid Phone Number Format!</label>
                                </div>
                                <label><span style="color:lightcoral">*</span>Sex</label>
                                <div class="form-group">
                                    <select id="staffSex" class="form-control required userInput">
                                        <option value="M">Male</option>
                                        <option value="F">Female</option>
                                    </select>
                                </div>
                                <label><span style="color:lightcoral">*</span>Country (Nationality)</label>
                                <div class="form-group">
                                     <select class="form-control required userInput" onchange="checkNationals(); false;" id="staffNationality" >
                                        <option value="">-- Select One --</option>
                                    </select>
                                    <label for="nationalsInput" id="natWarningUser" style="color: lightcoral">Please select a nationality!</label>
                                </div>
                                <label><span style="color:lightcoral">*</span>Date Of Birth</label>
                                <div class="input-group date" id="staffDOBDiv">
                                <input type='text' id="staffDOB" class="form-control userInput required" readonly />
                                <span class="input-group-addon">
                                    <span class="glyphicon glyphicon-calendar"></span>
                                </span>
                            </div>
                                <label><span style="color:lightcoral">*</span>Position Title</label>
                                <div class="form-group">
                                    <input id="staffTitle" class="form-control required userInput" /></div>
                                <label><span style="color:lightcoral">*</span>Permission</label>
                                <div class="form-group" id="permissions">
                                        <select class="form-control required userInput" onchange="getSelectedAccessProfileUser(); false;" id="permissionProfileDropdown">
                                            <option value="">-- Select One --</option>
                                        </select>
                                    </div>
                                <div id="permiss" class="form-group">
                                    <%--Checkbox Here--%>
                                </div>
                                <label><span style="color:lightcoral">*</span>Password (If no change, leave this blank)</label>
                                <div class="form-group">
                                    <input id="staffPwd" type="password" class="form-control required userInput" /></div>
                        </div>
                        <h4 id="emptyUserFields" style="color: lightcoral">Please fill in all the required fields with valid data (*) highlighted in yellow.</h4>
                        <div class="btn-group">               
                            <button type="button" class="btn btn-primary" onclick="clearStaffFields(true); false"><span class="glyphicon glyphicon-remove"></span> Clear All Fields</button>
                            <button type="button" id="newUser" class="btn btn-success" onclick="checkRequiredFieldsUser('new'); false"><span class="glyphicon glyphicon-plus"></span> Create New User</button>
                            <button type="button" id="updateUser" class="btn btn-success" onclick="checkRequiredFieldsUser('update'); false"><span class="glyphicon glyphicon-floppy-saved"></span> Update Existing User</button>       
                        </div>
                    </div>
    </div>
            </div>
                </div>
            <%}
                if (accessRightsStr.Contains('5'))
                { %>
            <!-- End of UserManagement -->

            <!-- PassManagement -->
            <div class="tab-pane maxHeight" id="PassManagement">
                <div id="passBodySample" style="width: 100%; height: inherit; margin: 0;" class="panel">
                    <div id="optionsForPass" class="col-sm-4 panel panel-primary inheritHeight" style="padding: 0">
                        <div class="panel-heading" >
                            <h4 style="margin:0">Edit Pass Settings </h4>
                        </div>
                        <div class="panel-body" style="overflow-y:auto;height: calc(100% - 40px);">
                         <div class="row">
                               <h4 style="margin: 0;">Select Size of pass:</h4>
                            <div class="btn-group">
                                <button type="button" class="btn btn-primary" onclick="changePassDimen('210mm','297mm');">A4</button>
                                <button type="button" class="btn btn-primary" onclick="changePassDimen('148mm','210mm');">A5</button>
                                <button type="button" class="btn btn-primary" onclick="changePassDimen('105mm','148mm');">A6</button>
                                <button type="button" class="btn btn-primary" onclick="changePassDimen('74mm','105mm');">A7</button>
                                <button type="button" class="btn btn-primary" onclick="changePassDimen('52mm','74mm');">A8</button>
                            </div>
                             <div class="btn-group">
                                <button type="button" class="btn btn-primary" onclick="toggleOrientation();">Toggle Pass Orientation</button>
                                
                            </div>
                             <br />
                             <div class=" row" style="width: 50%;margin:auto">
                                 <span class="form-control">Or Set a Custom Size(in mm):</span>
                                 <input type="text" class="form-control text-center" id="customSizePass" placeholder="E.g 150mm*180MM" />
                             </div>
                             <br />
                            <button type="button" class="btn btn-success" onclick="customDimenstions();">Custom Size</button>
                             </div>
                            <hr />
                            <div class="row">
                                <h4 style="margin-top: 0;">Add Text</h4>
                                Source of the text to be displayed:
                                <br />
                                <div>
                                  <select id="source" class="" style="width: 50%;margin: auto;color:black" onchange="ifCustom();">

                                      <option value="vnric">Visitor Nric</option>
                                      <option value="namesInput">Full Name</option>
                                      <option value="emailsInput">Email</option>
                                      <option value="mobilesInput">Contact Number</option>
                                      <option value="homesInput">Home Number</option>
                                      <option value="altInput">Alternate Number</option>
                                      <option value="addressInput">Address</option>
                                      <option value="postalsInput">Postal</option>
                                      <option value="sexinput">sex</option>
                                      <option value="nationsInput">Country (Nationality)</option>
                                      <option value="daterange">Date Of Birth</option>
                                      <option value="pInput">Purpose Of Visit</option>
                                      <option value="visitbookingdate">Visit Date</option>
                                      <option value="visitbookingtime">Visit Time</option>
                                      <option value="patientName">Patient Name</option>
                                      <option value="patientNric">Patient Nric</option>
                                      <option value="bedno">Bed Number</option>
                                      <option value="visLoc">Visit Location</option>
                                      <option value="purposeInput">Purpose</option>
                                      <option value="custom">Custom Text</option>
                                  </select>
                                    <label>Resizable:</label><input type="checkbox" id="textSizeable" /></div>
                                <input type="text" id="customText" placeholder="Custom Text Here" class="text-center" style="display:none" />
                                
                                
                                <div id="text-align">
                                    <label >Text-Align:</label>
                                     <label class="radio-inline">
                                      <input type="radio" name="textPosition" value="left"/>Left
                                    </label>
                                    <label class="radio-inline">
                                      <input type="radio" name="textPosition" value="center"/>Center
                                    </label>
                                    <label class="radio-inline">
                                      <input type="radio" name="textPosition" value="right"/>Right
                                    </label>
                                </div>
                                <div id="font-Size">
                                    <label>Font Size(in pt):</label>
                                    <input id="passFontSize" placeholder="Default size is 10.5pt" />
                                </div>

                                <button type="button" class="btn btn-success " id="addText"  onclick="addTextToPass();">Add Text</button>
                            </div>
                            <hr />
                            <div class="row">
                                <h4 style="margin-top: 0;">Add Barcode</h4>
                                <button type="button" class="btn btn-primary"  id="addBarcode" onclick="addBarCodeToPassLayout()">Add Barcode</button>
                            </div>
                            <hr />
                            <div>
                                <h4 style="margin-top: 0;">Add Image</h4>
                                <button type="button" class="btn btn-primary" id="addBgImg" onclick="$('#imageUpload').click();">Add Image</button>
                                <input type="file" id="imageUpload" onchange="createImageAndAdd(this)" class="hidden"/>
                            </div>

                        </div>
                    </div>
                    <div id="sampleOutput" style="background-color: initial; padding: 0; position: relative;" class=" col-sm-8 inheritHeight panel">
                        <div class="panel-heading">
                            <h4 style="margin: 0">Sample Pass Output</h4>
                        </div>
                        <div id="passContainers" style="background-color: darkslategray; overflow-y: auto; text-align: center; height: calc(100% - 40px); position: relative; padding: 0;" class=" panel-body vertical-center center-block ">
                            <button type="button" class="btn btn-success" onclick="savePassState()" style=" position: absolute; top: 0; left: calc(50% - 70px);  ">Save Pass Format</button>
                          

                           

                        </div>

                    </div>
                </div>


            </div>
            <!-- End of PassManagement -->

            <%}
                if (accessRightsStr.Contains('6'))
                { %>
    <!-- ContactTracing -->
    <div class="tab-pane maxHeight" id="ContactTracing">
        <%--Final Unified Tracing UI--%>
        <div class="row" id="unifiedTrace">
            <h3 style="">Enter query time period and bed(s)/location(s) to begin.</h3>
           
            <div class="form-group col-sm-offset-1 col-sm-10" id="unified_query_params">
                <div class="col-sm-2">
                    <div class="input-group date" id="unifiedquery_startdatetime">
                        <input type='text' id="uq_startdatetime" class="form-control required" placeholder="Start DateTime" />
                        <span class="input-group-addon">
                            <span class="glyphicon glyphicon-calendar"></span>
                        </span>
                    </div>
                </div>

                <div class="col-sm-2">
                    <div class="input-group date" id="unifiedquery_enddatetime">
                        <input type='text' id="uq_enddatetime" class="form-control required" placeholder="End DateTime" />
                        <span class="input-group-addon">
                            <span class="glyphicon glyphicon-calendar"></span>
                        </span>
                    </div>
                </div>
                <div id="unifiedquery_bednos" class="input-group col-sm-8">
                    <div class="col-sm-6">
                        <input class="form-control" id="uq_bednos" placeholder="Beds: 1101, 1103, 2101-2105 " type="text" />
                    </div>
                    <div class="col-sm-6">
                        <input class="form-control" id="uq_loc" placeholder="Location: NKF" type="text" />
                    </div>
                    <span class="input-group-btn">
                    <button class="btn btn-warning" id="execute_unifiedTrace" onclick="unifiedTrace(); false;"><span class="glyphicon glyphicon-search"></span> Trace</button>
                        <%--<button class="btn btn-warning" id="execute_expressTrace" onclick="expressTrace(); false;"><span class="glyphicon glyphicon-search"></span> Trace Express Entries</button>--%>
                    </span>
                </div>
                <div class="input-group col-sm-2">
                    <div class="checkbox">
                        <label for="expressTraceCheck"></label>
                        <input type="checkbox" id="expressTraceCheck" name="declare" value="true" class="regInput" />Trace Express Entries<br />
                    </div>
                </div>
                <script>
                    var uq_bednos = document.getElementById('uq_bednos'),
                        uq_loc = document.getElementById('uq_loc');

                    function enableToggle(current, other) {
                        other.disabled = current.value.replace(/\s+/,'').length > 0;
                    }

                    uq_bednos.onkeyup = function () {
                        enableToggle(this, uq_loc);
                    }
                    uq_loc.onkeyup = function () {
                        enableToggle(this, uq_bednos);
                    }
                </script>
                
            </div>
            <div class="form-group" id="uq_results">
                <table id ="uq_resultstable" class="table table-responsive table-hover" style:"padding-left:10px padding-right:10px">
                    <thead id="uq_resultstable_head">
                        <tr>
                            <th>Registration Location</th>
                            <th>Registration Bed No.</th>
                            <th>Check-in Time</th>
                            <th>Exit Time</th>
                            <th>Temperature</th>>
                            <th>Name</th>
                            <th>NRIC</th>
                            <th>Gender</th>
                            <th>Date of Birth</th>
                            <th>Contact Number</th>
                            <th>Home Address</th>
                            <th>Postal Code</th>
                            <th>Country (Nationality)</th>
                            <th>Form Answers</th>
                            <th>Registered</th>
                            <th>Scanned</th>
                        </tr>
                    </thead>
                    <tbody id="uq_resultstable_body">
                    </tbody>
                </table>

                <script>
                    $(document).ready(function () {
                        var datetime_str = new Date().toString();
                        var bednos = uq_bednos.value;
                        var location = uq_loc.value;
                        var traceby = bednos
                        if (bednos.length === 0) {
                            traceby = location
                        }

                        var table = $('#uq_resultstable').DataTable({
                            "columnDefs": [
                                { className: "export_only", "targets": [0] },

                            ],
                            "searching": false,
                            "lengthMenu": [[10, 25, 50, -1], [10, 25, 50, "All"]],
                            "deferRender": true,
                            dom: 'Bfrtipl',
                            stateSave: true,
                            buttons: [
                            'colvis',
                            {
                                extend: 'csvHtml5',
                                title: 'Trace done on ' + datetime_str
                            },
                            {
                                extend: 'excelHtml5',
                                title: 'Trace done on ' + datetime_str
                            },
                            {
                                extend: 'copyHtml5',
                                text: 'Copy Numbers',
                                header: false,
                                footer: false,
                                exportOptions: {
                                    columns: [9]
                                }
                            }
                            ],
                            language: {
                                buttons: {
                                    colvis: 'Toggle columns',
                                }
                            }
                        });
                        //table.columns('export_only').visible(false);
                        table.columns([4, 7, 8, 10, 11, 13]).visible(false, false);
                        $('#uq_resultstable').prop("style", "width:100%");
                        $('#uq_resultstable').removeClass("dataTable");
                        $('#uq_resultstable_info').removeClass("dataTables_info");
                        $('#uq_resultstable_length').removeClass("dataTables_length");
                    });
                </script>
            </div>
        </div>
    </div>
    <!-- End of ContactTracing -->
    <!-- Dashboard -->
    <div class="tab-pane maxHeight" id="Dashboard">
        <div class="row" id="dashboard_frame">
            <h3 style="">Select time period to view visitor statistics.</h3>
            <div class="form-group col-sm-offset-1 col-sm-10" id="dashboard_params">
                <div class="col-sm-2 col-sm-offset-4">
                    <div class="input-group date" id="dashboard_startdatetime">
                        <input type='text' id="dash_startdatetime" class="form-control required" placeholder="Start DateTime" />
                        <span class="input-group-addon">
                            <span class="glyphicon glyphicon-calendar"></span>
                        </span>
                    </div>
                </div>

                <div class="col-sm-2">
                    <div class="input-group date" id="dashboard_enddatetime">
                        <input type='text' id="dash_enddatetime" class="form-control required" placeholder="End DateTime" />
                        <span class="input-group-addon">
                            <span class="glyphicon glyphicon-calendar"></span>
                        </span>
                    </div>
                </div>

                <div class ="col-sm-2">
                    <span class="input-group-btn">
                    <button class="btn btn-warning" id="fill_dashboard" onclick="fillDashboard(); false;"><span class="glyphicon glyphicon-search"></span> View</button>
                    </span>
                </div>

                <script type="text/javascript"> //Shift to separate Script
                    $(function () {
                        $('#dashboard_startdatetime').datetimepicker(
                            {
                                defaultDate: new Date(new Date().setDate(new Date().getDate() - 1)), //1 day ago
                                maxDate: new Date(new Date().setDate(new Date().getDate() - 1)),
                                format: 'YYYY-MM-DD'
                            }
                            );
                    });
                    $(function () {
                        $('#dashboard_enddatetime').datetimepicker({
                            defaultDate: new Date(new Date().setDate(new Date().getDate() - 1)),
                            maxDate: new Date(new Date().setDate(new Date().getDate() - 1)),
                            format: 'YYYY-MM-DD'
                        });
                    });
                </script>                
            </div>
            <div class="col-sm-offset-1 col-sm-10" id="chart_container">
                <div class="col-sm-12" id="time_chart_container">
                    <div id="hourOfDay_chart" style="height: 300px; width: 675px; display: inline-block;"></div>
                    <div id="dayOfWeek_chart" style="height: 300px; width: 425px; display: inline-block;"></div>
                </div>
                <div class ="col-sm-12" id="demographic_chart_container">
                    <div id="age_chart" style="height: 300px; width: 675px; display: inline-block;"></div>
                    <div id="gender_chart" style="height: 300px; width: 425px; display: inline-block;"></div>
                </div>
                <div class ="col-sm-12" id="dwelltime_chart_container">
                    <div id="dwelltime_chart" style="height: 300px; width: 100%; display: inline-block;"></div>
                </div>
                <div class ="col-sm-12" id="location_chart_container">
                    <div id="location_chart" style="height: 300px; width: 100%; display: inline-block;"></div>
                </div>
            </div>
        </div>
    </div>
    <!-- End Dashboard -->
            <!-- SMS -->
            <div class="tab-pane maxHeight" id="SMS">
                <div id="SMSDiv" class="jumbotron center-block" style="text-align:left; width:50%">
                    <h3 style="color:lightblue">Send SMS</h3>
                    <label>Send To</label>
                    <div class="form-group">
                        <input type="text" class="form-control" id="targetVisitor" placeholder="Please enter number(s) like 9712342,8128763" />
                    </div>
                    <label>Message</label>
                    <div class="form-group">
                        <%--<input type="text" class="form-control" id="messageContent" />--%>
                        <textarea id="smsMessage" class="form-control" rows="3" placeholder="Enter message content here"></textarea>
                    </div>
                    <button class="btn btn-success btn-block" id="sendSMS" onclick="checkSMSNumber(); false;"><span class="glyphicon glyphicon-send"></span> Send SMS</button>
                    <label style="color:lightcoral" id="invalidSMSNumber">Invalid Contact Number</label>
                    <label style="color:lightcoral" id="emptyMessage">Please enter message content!</label>
                </div>
            </div>
            <!-- End of SMS -->
    <%} %>
    </div>
        </div>
   
     <%if (accessRightsStr.Contains('4'))
         { %>
    <script type="text/javascript" src="<%= Page.ResolveClientUrl("~/Webpage/Staff/default.js") %>"></script>
    <%} if (accessRightsStr.Contains('3'))
        {%>
    <script type="text/javascript" src="<%= Page.ResolveClientUrl("~/Webpage/Staff/TerminalCalls/adminTerminal.js") %>"></script>
    <%} if (accessRightsStr.Contains('2')) { %>
    <script type="text/javascript" src="<%= Page.ResolveClientUrl("~/Webpage/Staff/QuestionaireManagement/loadQuestionaire.js") %>"></script>
    <%} %>
    <script type="text/javascript" src="<%= Page.ResolveClientUrl("~/Scripts/regData.js") %>"></script>
    <script type="text/javascript" src="<%= Page.ResolveClientUrl("~/Scripts/fieldValidations.js") %>"></script>
     <%if (accessRightsStr.Contains('1'))
         { %>
    <script type="text/javascript" src="<%= Page.ResolveClientUrl("~/Scripts/qz-tray.js") %>"></script>
    <script type="text/javascript" src="<%= Page.ResolveClientUrl("~/Scripts/kc.fab.js") %>"></script>
    <script type="text/javascript" src="<%= Page.ResolveClientUrl("~/Webpage/Staff/registrationPageScripts.js") %>"></script>
    <script type="text/javascript" src="<%= Page.ResolveClientUrl("~/Webpage/Staff/patientAutocomplete.js") %>"></script>
     <%} if (accessRightsStr.Contains('4'))
             { %>
    <script type="text/javascript" src="<%= Page.ResolveClientUrl("~/Webpage/Staff/UserManagement/loadUsers.js") %>"></script>
    <%}if (accessRightsStr.Contains('6'))
        { %>
    <script type="text/javascript" src="<%= Page.ResolveClientUrl("~/Scripts/jquery.dataTables.min.js") %>"></script>
    <script type="text/javascript" src="<%= Page.ResolveClientUrl("~/Scripts/dataTables.buttons.min.js") %>"></script>
    <script type="text/javascript" src="<%= Page.ResolveClientUrl("~/Scripts/buttons.colVis.min.js") %>"></script>
    <script type="text/javascript" src="<%= Page.ResolveClientUrl("~/Scripts/buttons.flash.min.js") %>"></script>
    <script type="text/javascript" src="<%= Page.ResolveClientUrl("~/Scripts/jszip.min.js") %>"></script>
    <script type="text/javascript" src="<%= Page.ResolveClientUrl("~/Scripts/pdfmake.min.js") %>"></script>
    <script type="text/javascript" src="<%= Page.ResolveClientUrl("~/Scripts/vfs_fonts.js") %>"></script>
    <script type="text/javascript" src="<%= Page.ResolveClientUrl("~/Scripts/buttons.html5.min.js") %>"></script>
    <script type="text/javascript" src="<%= Page.ResolveClientUrl("~/Scripts/buttons.print.min.js") %>"></script>
    <script type="text/javascript" src="<%= Page.ResolveClientUrl("~/Scripts/dataTables.bootstrap.min.js") %>"></script>
    <script type="text/javascript" src="<%= Page.ResolveClientUrl("~/Webpage/Staff/ContactTracing/query.js") %>"></script>
    <script type="text/javascript" src="<%= Page.ResolveClientUrl("~/Webpage/Staff/SMS/sms.js") %>"></script>
    <%} if (accessRightsStr.Contains('5') || accessRightsStr.Contains('1')) {%>
    <script type="text/javascript" src="<%= Page.ResolveClientUrl("~/Webpage/Staff/PassManagement/passManage.js") %>"></script>
    <%} %>
    <script type="text/javascript">
        var user = '<%= Session["username"].ToString() %>';
    </script>
   
</body>
   
</html>
