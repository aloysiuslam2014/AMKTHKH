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

.purposeBorder {
    outline: 1px solid black;
}
    </style>
</head>
<body onload="hideTags()">
    <form id="selfregistration" runat="server">
        <div id="maincontainer" class="container-fluid" runat="server">
            <nav class="navbar navbar-default navbar-fixed-top">
                <div class="container-fluid contentNav" style="width:100%;">
                    <div class="navbar-header ">
                        <a class="navbar-brand"><b>Thye Hua Kwan Hospital</b></a>
                    </div>
                    <div class="collapse navbar-collapse" id="navbar">
                    
                            <div class="nav navbar-nav navbar-right" style="margin-top:5px">
                                <button type="button" runat="server" class="btn btn-primary" onclick="reloadPage(); false;"><span class="glyphicon glyphicon-refresh"></span> New Registration</button>
                            </div>
                        
                        </div>
                </div>
            </nav>
            <br />
            <br />
            <br />
            <a data-controls-modal="myModal" data-backdrop="static" data-keyboard="false" href="#/"></a>
                <div class="modal fade" id="myModal" tabindex="-1" role="dialog" aria-labelledby="memberModalLabel" aria-hidden="true">
                    <div class="modal-dialog">
                        <div class="modal-content">
                            <div class="modal-header text-center">
                                <img src="../../Assets/hospitalLogo.png" class="img img-responsive" /><br />
                                <h3 class="modal-title">Visitor Registration</h3><br />
                                <div class="input-group">
                                          <span class="input-group-addon" id="basic-addon">NRIC/FIN</span>
                                          <input type="text" class="form-control" id="selfRegNric" placeholder="Please enter a Singapore-based ID Number" aria-describedby="basic-addon" />
                                        </div>    
                                <h5 style="text-align:center; font-style:italic">Visitors without a valid NRIC, please approach our staff at the front counter</h5>
                                <h5 id="emptyNricWarning">Please enter your NRIC/Identification Number!</h5>
                                <button class="btn btn-block btn-success" id="submitNric" onclick="showVisitDetails(); false;"><span class="glyphicon glyphicon-ok"></span> Submit</button>
                                <h5 id="nricWarning" style="color: lightcoral">Invalid ID number! Please register at the front counter.</h5>
                            </div>
                            <%--<div class="modal-body text-center">
                                
                            </div>--%>
                            <%--<div class="modal-footer">
                                
                            </div>--%>
                        </div>
                    </div>
                </div>
            <a data-controls-modal="successModal" data-backdrop="static" data-keyboard="false" href="#/"></a>
                <div class="modal fade" id="successModal" tabindex="-1" role="dialog" aria-labelledby="memberModalLabel" aria-hidden="true">
                    <div class="modal-dialog">
                        <div class="modal-content">
                            <div class="modal-header text-center">
                                <img src="../../Assets/hospitalLogo.png" class="img img-responsive" /><br />
                                <h4 class="modal-title" id="memberModalLabel1" style="color:white">Online Registration Recorded</h4>
                            </div>
                            <div class="modal-body text-center">
                                    <label>Visitor registration has been recorded at <%=TimeZone.CurrentTimeZone.ToUniversalTime(DateTime.Now).AddHours(8).ToString() %>.</label>
                                    <label>Please proceed to the screening counter.</label>
                            </div>
                            <div class="modal-footer">
                                <button class="btn btn-block btn-danger" id="closeSuccessButton" onclick="reloadPage(); false;"><span class="glyphicon glyphicon-off"></span> Close</button>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="col-md-6 col-md-offset-3">
                    
                    <div class="row" id="visitDetailsDiv">
                        <div class="jumbotron">
                        <h3>Visit Details</h3>
                                <label for="pInput"><span style='color:lightcoral'>*</span>Visit Purpose</label> <%--Check for Purpose of Visit--%>
                                <div class="form-group">
                                    <select class="form-control" id="pInput" onchange="purposePanels(); false;">
                                        <option value="">-- Select One --</option>
                                        <option value="Visit Patient">Visit Patient</option>
                                        <option value ="Other Purpose">Other Purpose</option>
                                        </select>
                                    </div>
                                <div id="patientpurposevisit" class="container-fluid" runat="server"> <%--Show this only when Visit Purpose is "Visit Patient"--%>
                                    <label for="patientName"><span style='color:lightcoral'>*</span>Patient Name</label> <%--AJAX Call to search for Patient Name--%>
                                    <div class="form-group">
                                        <input type="text" runat="server" class="form-control" id="patientName" />
                                    </div>
                                    <%--<label for="patientNric">Patient NRIC</label>--%>
                                    <div class="form-group">
                                        <input type="hidden" runat="server" class="form-control" id="patientNric" />
                                    </div>
                                    <label for="bedno"><span style='color:lightcoral'>*</span>Bed Number</label> <%--Bed Number--%>
                                <div class="form-group">
                                    <input type="text" runat="server" class="form-control" id="bedno" />
                                </div>
                                    <div class="form-group">
                                        <button id="validatePatientButton" value="Validate Patient Information" class="btn btn-warning" onclick="validatePatient(); false;"><span class="glyphicon glyphicon-check"></span> Check Patient</button>
                                        <label for="validatePatientButton" id="patientStatusGreen" style="color:green">Please continue with the form</label>
                                    <label for="validatePatientButton" id="patientStatusRed" style="color:lightcoral">Invalid patient or bed number. Please proceed to the front counter</label>
                                        <label for="validatePatientButton" id="patientStatusNone" style="color:lightcoral">Please fill in the details of the patient your are visiting! If you are unsure, please approach the front desk personnel for assistance.</label>
                                    </div>
                                </div>
                                <div id="otherpurposevisit" class="container-fluid" runat="server"> <%--Show this only when Visit Purpose is "Other Purpose"--%>
                                    <label for="visLoc"><span style='color:lightcoral'>*</span>Visit Location</label>
                                    <div class="form-group">
                                    <select class="form-control" id="visLoc">
                                        <option value="">-- Select One --</option>
                                        </select>
                                        <label for="visLoc" id="locWarning" style="color: lightcoral">Please select a visit location!</label>
                                    </div>
                                    <label for="purposeInput"><span style='color:lightcoral'>*</span>Purpose of Visit</label>
                                    <div class="form-group">
                                        <input type="text" runat="server" class="form-control" id="purposeInput" />
                                    </div>
                                </div>
                                <label for="visitbookingdate"><span style='color:lightcoral'>*</span>Visit Date (DD-MM-YYYY)</label>
                                <%--Visit Time--%>
                            <div class="form-group">
                                    <div class="input-group date" id="visitbookingdatediv">
                                    <input type='text' id="visitbookingdate" class="form-control required" readonly />
                                    <span class="input-group-addon">
                                        <span class="glyphicon glyphicon-calendar"></span>
                                    </span>
                                </div>
                                </div>
                                <label for="visitbookingtime"><span style='color:lightcoral'>*</span>Visit Time (HH:mm)</label>
                                <%--Visit Time--%>
                            <div class="form-group">
                                <select class="form-control required" onchange="checkTime(); false;" id="visitbookingtime">
                                        <option value="">-- Select One --</option>
                                    </select>
                                <label for="declaration" id="timelabel" style="color: lightcoral">Please choose a Visit Time!</label>
                                </div>
                    </div>
                        </div>
                    <div class="row">
                        <div id="userDetails" class="jumbotron">
                        <div id="changeddetailsdeclaration" style="text-align:left">
                            <label for="changeddetails">I have changed my contact details since the last visit</label>
                                <div class="form-group">
                                <div class="checkbox" id="changeddetails">
                                    <label for="yesopt">
                                    <input type="checkbox" id="changed" onchange="amendVisitorDetails(); false;" name="yesopt" value="Yes" />Yes</label>
                                    <input type="hidden" runat="server" class="form-control" id="amend" value="0" />
                                </div></div>
                                    </div>
                        <div id="newusercontent" runat="server">
                            <div style="text-align:left">
                                    <h3>Personal Details</h3>
                                    <label for="namesinput"><span style='color:lightcoral'>*</span>Full Name</label>
                                    <div class="form-group">
                                        <input type="text" runat="server" class="form-control required" id="namesInput" />
                                    </div>
                                    <%--<label for="emailinput">Email address</label>
                                    <div class="form-group">
                                        <input type="text" runat="server" class="form-control" id="emailsInput" onchange="ValidateEmail(); false"/>
                                        <label for="emailsInput" id="emailWarning" style="color: lightcoral">Invalid Email Address Format!</label>
                                    </div>--%>
                                    <label for="nricsInput"><span style='color:lightcoral'>*</span>NRIC</label>
                                    <div class="form-group">
                                        <input type="text" runat="server" class="form-control required" id="nricsInput" readonly />
                                    </div>
                                    <label for="mobileinput"><span style='color:lightcoral'>*</span>Mobile Number</label>
                                    <div class="form-group">
                                        <input type="text" runat="server" class="form-control required" id="mobilesInput" />
                                        <label for="mobilesInput" id="mobWarning" style="color:lightcoral">Invalid Phone Number Format!</label>
                                    </div>
                                    <label for="sexinput"><span style='color:lightcoral'>*</span>Gender:</label>
                                    <div class="form-group">
                                        <select class="form-control" id="sexinput" onchange="checkGender(); false;">
                                            <option value="">-- Select One --</option>
                                            <option value="M">Male</option>
                                            <option value="F">Female</option>
                                        </select>
                                        <label for="sexinput" id="sexWarning" style="color: lightcoral">Please select a gender!</label>
                                    </div>
                                    <label for="nationalinput"><span style='color:lightcoral'>*</span>Nationality</label>
                                    <div class="form-group">
                                        <select class="form-control required" onchange="checkNationals(); false;" id="nationalsInput">
                                            <option value="">-- Select One --</option>
                                        </select>
                                        <label for="nationalsInput" id="natWarning" style="color: lightcoral">Please select a nationality!</label>
                                    </div>
                                    <label for="daterange"><span style='color:lightcoral'>*</span>Date of Birth (DD-MM-YYYY)</label>
                                    <div class="form-group">
                                    <div class="input-group date" id="datetimepicker">
                                        <input type='text'id="daterange" class="form-control required" onchange="checkDOB(); false;" />
                                        <span class="input-group-addon">
                                            <span class="glyphicon glyphicon-calendar"></span>
                                        </span>
                                    </div>
                                    </div>
                                    <%--<label for="homeinput">Home Number</label>
                                    <div class="form-group">
                                        <input type="text" runat="server" class="form-control" id="homesInput" />
                                        <label for="homesInput" id="homeWarning" style="color:lightcoral">Invalid Phone Number Format!</label>
                                    </div>
                                    <label for="altInput">Alternate Number</label>
                                    <div class="form-group">
                                        <input type="text" runat="server" class="form-control" id="altInput" />
                                        <label for="altInput" id="altWarning" style="color:lightcoral">Invalid Phone Number Format!</label>
                                    </div>--%>
                                   <label for="addressinput"><span style='color:lightcoral'>*</span>Address</label>
                                    <div class="form-group">
                                        <input type="text" runat="server" class="form-control required" id="addresssInput" />
                                    </div>
                                    <label for="postalinput"><span style='color:lightcoral'>*</span>Postal Code</label>
                                    <div class="form-group">
                                        <input type="text" runat="server" class="form-control required" id="postalsInput" />
                                        <label for="postalsInput" id="posWarning" style="color: lightcoral">Invalid Postal Code Format!</label>
                                    </div>
                                </div>
                                </div>
                            </div>
                        </div>
                    <div class="row">
                        <div id="staticinfocontainer" runat="server">
                            <div class="jumbotron" style="text-align:left">                            
                                <h3>Health Screening Form</h3>
                               <div id="questionaireForm">
                                    <!-- load questionaires here -->
                                </div>
                                <div class="checkbox">
                                    <label for="declaration">
                            <input type="checkbox" id="declaration" name="declare" onchange="declarationValidation(); false;" value="true" />I have entered the required information to the best of my knowledge and ability</label><br />
                                    <input type="hidden" name="declare" value="false" />
                            <label for="declaration" id="declabel" style="color:lightcoral">Please ensure that you have "Check Patient" details and check this option to continue</label>
                                    <h4 id="emptyFields" style="color:lightcoral">Please fill in all the required fields with valid data (*) highlighted in yellow.</h4>
                        </div>
                        <button class="btn btn-block btn-success" id="submitNewEntry" onclick="checkRequiredFields(); false;"><span class="glyphicon glyphicon-list-alt"></span> Submit</button> <%--Copy to Tables without confirmation--%>

                        </div>
                            </div>
                    </div>
                </div>
                </div>
    </form>
    <script type="text/javascript" src="<%= Page.ResolveClientUrl("~/Scripts/fieldValidations.js") %>"></script>
    <script type="text/javascript" src="<%= Page.ResolveClientUrl("~/Webpage/SelfReg/selfRegistrationScript.js") %>"></script>
    <input type="hidden" id="isNew" value="true" />
</body>
</html>
