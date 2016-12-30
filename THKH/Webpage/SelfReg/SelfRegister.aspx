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
                <div class="container-fluid contentNav">
                    <div class="navbar-header ">
                        <a class="navbar-brand"><b>Thye Hua Kwan Hospital</b></a>
                    </div>
                    <div class="collapse navbar-collapse" id="navbar">
                    <ul class="nav navbar-nav navbar-right">
                    <li>
                        <a>
                            <div>
                                <input type="button" runat="server" class="btn btn-default" onclick="reloadPage(); false;"><span class="glyphicon glyphicon-refresh"></span> New Registration</input>
                            </div>
                        </a>
                    </li>
                </ul>
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
                                <h4 class="modal-title" id="memberModalLabel">Please enter your NRIC/Identification Number to Begin</h4>
                            </div>
                            <div class="modal-body text-center">
                                    NRIC: <input type="text" id="selfRegNric" class="form-control" autofocus/>
                                <h4 id="emptyNricWarning">Please enter your NRIC/Identification Number!</h4>
                            </div>
                            <div class="modal-footer">
                                <button class="btn btn-block btn-success" id="submitNric" onclick="showVisitDetails(); false;"><span class="glyphicon glyphicon-ok"></span> Submit</button>
                                <h4 id="nricWarning" style="color: red">Invalid/Non-Singapore Based ID! Please register at the Front Counter.</h4>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="col-md-6 col-md-offset-3">
                    
                    <div class="row" id="visitDetailsDiv">
                        <div class="jumbotron">
                        <h3>Visit Details</h3>
                                <label for="pInput">Visit Purpose</label> <%--Check for Purpose of Visit--%>
                                <div class="form-group">
                                    <select class="form-control" id="pInput" onchange="purposePanels(); false;">
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
                                    <%--<label for="patientNric">Patient NRIC</label>--%>
                                    <div class="form-group">
                                        <input type="hidden" runat="server" class="form-control" id="patientNric" />
                                    </div>
                                    <label for="bedno">Bed Number:</label> <%--Bed Number--%>
                                <div class="form-group">
                                    <input type="text" runat="server" class="form-control" id="bedno" />
                                </div>
                                    <div class="form-group">
                                        <button id="validatePatientButton" value="Validate Patient Information" class="btn btn-warning" onclick="validatePatient(); false;"><span class="glyphicon glyphicon-check"></span> Validate Patient</button>
                                        <label for="validatePatientButton" id="patientStatusGreen" style="color:green">Patient Found! Please fill up the rest of the form.</label>
                                    <label for="validatePatientButton" id="patientStatusRed" style="color:red">Patient Not Found! Please Register at the Front Counter.</label>
                                        <label for="validatePatientButton" id="patientStatusNone" style="color:red">Please the details of the patient your are visiting! If you are unsure, please approach the front desk personnel for assistance.</label>
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
                                <label for="visitbookingdate">Visit Date</label><label for="visitbookingdate" id="comp21" style="color: red">*</label>
                                <%--Visit Time--%>
                            <div class="form-group">
                                    <div class="input-group date" id="visitbookingdatediv">
                                    <input type='text' id="visitbookingdate" class="form-control required" />
                                    <span class="input-group-addon">
                                        <span class="glyphicon glyphicon-calendar"></span>
                                    </span>
                                </div>
                                </div>
                                <label for="visitbookingtime">Visit Time</label><label for="visitbookingtime" id="comp11" style="color: red">*</label>
                                <%--Visit Time--%>
                            <div class="form-group">
                                    <div class="input-group date" id="visitbookingtimediv">
                                    <input type='text' id="visitbookingtime" class="form-control required" />
                                    <span class="input-group-addon">
                                        <span class="glyphicon glyphicon-time"></span>
                                    </span>
                                </div>
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
                                </div></div>
                                    </div>
                        <div id="newusercontent" runat="server">
                            <div style="text-align:left">
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
                                        <input type="text" runat="server" class="form-control required" id="nricsInput" />
                                    </div>
                                    <label for="mobileinput">Mobile Number</label><label for="mobilesinput" id="comp0" style="color:red">*</label>
                                    <div class="form-group">
                                        <input type="text" runat="server" class="form-control required" id="mobilesInput" />
                                        <label for="mobilesInput" id="mobWarning" style="color:red">Invalid Phone Number Format!</label>
                                    </div>
                                    <label for="homeinput">Home Number</label>
                                    <div class="form-group">
                                        <input type="text" runat="server" class="form-control" id="homesInput" />
                                        <label for="homesInput" id="homeWarning" style="color:red">Invalid Phone Number Format!</label>
                                    </div>
                                    <label for="altInput">Alternate Number</label>
                                    <div class="form-group">
                                        <input type="text" runat="server" class="form-control" id="altInput" />
                                        <label for="altInput" id="altWarning" style="color:red">Invalid Phone Number Format!</label>
                                    </div>
                                    <label for="addressinput">Address</label><label for="existnric" id="comp4" style="color:red">*</label>
                                    <div class="form-group">
                                        <input type="text" runat="server" class="form-control required" id="addresssInput" />
                                    </div>
                                    <label for="postalinput">Postal Code</label><label for="existnric" id="comp5" style="color:red">*</label>
                                    <div class="form-group">
                                        <input type="text" runat="server" class="form-control required" id="postalsInput" />
                                    </div>
                                    <label for="sexinput">Gender:</label><label for="existnric" id="comp19" style="color:red">*</label>
                                    <div class="form-group">
                                        <select class="form-control" id="sexinput">
                                            <option value="M">Male</option>
                                            <option value="F">Female</option>
                                        </select>
                                    </div>
                                    <label for="nationalinput">Nationality</label><label for="existnric" id="comp6" style="color:red">*</label>
                                    <div class="form-group">
                                        <%--<input type="text" runat="server" class="form-control required" id="nationalsInput" />--%>
                                        <select class="form-control required" id="nationalsInput">
                                            <option value="">-- Select One --</option>
                                        </select>
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
                            </div>
                        </div>
                    <div class="row">
                        <div id="staticinfocontainer" runat="server">
                            <div class="jumbotron" style="text-align:left">                            
                                <h3>Health Screening Questionnaire</h3>
                               <div id="questionaireForm">
                                    <!-- load questionaires here -->
                                </div>
                                <div class="checkbox">
                                    <label for="declaration">
                            <input type="checkbox" id="declaration" name="declare" onchange="declarationValidation(); false;" value="true" />I declare that the above information given is accurate</label><br />
                                    <input type="hidden" name="declare" value="false" />
                            <label for="declaration" id="declabel" style="color:red">Please validate your patient details & check this option to continue</label>
                                    <h4 id="emptyFields" style="color:red">Please fill in all the required fields with valid data (*) highlighted in yellow.</h4>
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
