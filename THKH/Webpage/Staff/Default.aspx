<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Default.aspx.cs" Inherits="THKH.Webpage.Staff.Default" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <meta charset="utf-8">
    <title>Welcome <%= Session["username"].ToString()%> | Ang Mo Kio - Thye Hwa Kuan</title>
    <link href="~/Content/bootstrap.min.css" rel="stylesheet" />
    <script type="text/javascript" src="<%= Page.ResolveClientUrl("~/Scripts/jquery-3.1.1.min.js") %>"></script>
    <script type="text/javascript" src="<%= Page.ResolveClientUrl("/Scripts/moment.min.js") %>"></script>
    <script type="text/javascript" src="<%= Page.ResolveClientUrl("/Scripts/w3data.js") %>"></script>
    <script type="text/javascript" src="<%= Page.ResolveClientUrl("~/Scripts/bootstrap.min.js") %>"></script>
    <script type="text/javascript" src="<%= Page.ResolveClientUrl("/Scripts/bootstrap-datetimepicker.js") %>"></script>

    <link href="~/CSS/default.css" rel="stylesheet" />
    <link href="~/CSS/adminTerminal.css" rel="stylesheet" />





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
                        <a href="#TerminalManagement" data-toggle="tab" onclick="loadTerminals()">Terminals Management
                        </a>
                    </li>
                    <li>
                        <a href="#UserManagement" data-toggle="tab">User Management
                        </a>
                    </li>
                    <li>
                        <a href="#PassManagement" data-toggle="tab">Pass Management
                        </a>
                    </li>
                </ul>

                <ul class="nav navbar-nav navbar-right">
                    <li><a id="logAnchor" href="#">
                        <form id="logbtn" runat="server">
                            <div>
                                <label>Welcome, <%= Session["username"].ToString()%></label>
                                <asp:Button ID="logout" class="btn" Text="logout" OnClick="logout_Click" runat="server" />
                            </div>
                        </form>

                    </a></li>
                </ul>
            </div>
        </div>
    </nav>

    <div id="main" class="container containerMain">
        <div class="tab-content tab-content-main maxHeight" style="border: 0;" id="generalContent">
            <!-- Registration -->
            <div class="tab-pane maxHeight" id="registration">
           
                    <div class="row">
                        <div id="nurseInputArea" class="col-md-6 col-md-offset-3">
                            <div class="jumbotron" style="text-align: left">
                                <label class="control-label" for="nric">Visitor's NRIC:</label>
                                <div class="input-group date" id="nricinputgroup">
                                    <input runat="server" id="nric" class="form-control required" type="text" autofocus />
                                    <span class="input-group-btn">
                                        <button class="btn btn-warning" onclick="checkExistOrNew(); false;" runat="server">Check NRIC</button>
                                    </span>
                                </div>
                                <h4 id="emptyNricWarning" style="color:red">Please enter your NRIC/Identification Number!</h4>
                                <h4 id="nricWarning" style="color:red">Non-Singapore Based NRIC/ID!</h4>
                                <br />
                                <label class="control-label" for="temp">Temperature</label><label for="temp" id="comp0" style="color: red">*</label>
                                <input runat="server" id="temp" class="form-control required" type="text" onchange="checkTemp(); false;" />
                                <h4 id="tempWarning" style="color:red">Visitor's Temperature is above 37.6 Degrees Celcius!</h4>
                            </div>
                        </div>
                    </div>
                    <h4 id="emptyFields" style="color:red">Please fill in all the required fields (*).</h4>
                    <div class="row">
                        <div id="newusercontent" class="col-sm-6" runat="server">
                            <div class="jumbotron" style="text-align: left">
                                <h3>Personal Details</h3>
                                <label for="namesinput">Full Name</label><label for="namesinput" id="comp1" style="color: red">*</label>
                                <div class="form-group">
                                    <input type="text" runat="server" class="form-control required" id="namesInput" />
                                </div>
                                <label for="emailinput">Email address</label>
                                <div class="form-group">
                                    <input type="text" runat="server" class="form-control" id="emailsInput" />
                                </div>
                                <label for="mobileinput">Mobile Number</label><label for="namesinput" id="comp12" style="color: red">*</label>
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
                                <label for="addressinput">Address</label><label for="addressinput" id="comp2" style="color: red">*</label>
                                <div class="form-group">
                                    <input type="text" runat="server" class="form-control required" id="addresssInput" />
                                </div>
                                <label for="postalinput">Postal Code</label><label for="postalinput" id="comp3" style="color: red">*</label>
                                <div class="form-group">
                                    <input type="text" runat="server" class="form-control required" id="postalsInput" />
                                </div>
                                <label for="sexinput">Gender</label><label for="sexinput" id="comp4" style="color: red">*</label>
                                <div class="form-group">
                                    <select class="form-control required" id="sexinput">
                                        <option value="M">Male</option>
                                        <option value="F">Female</option>
                                    </select>
                                </div>
                                <label for="nationalinput">Nationality</label><label for="nationalinput" id="comp5" style="color: red">*</label>
                                <div class="form-group">
                                    <input type="text" runat="server" class="form-control required" id="nationalsInput" />
                                </div>
                                <label for="daterange">Date of Birth</label><label for="daterange" id="comp6" style="color: red">*</label>
                                <div class="input-group date" id="datetimepicker">
                                    <input type='text' id="daterange" class="form-control required" />
                                    <span class="input-group-addon">
                                        <span class="glyphicon glyphicon-calendar"></span>
                                    </span>
                                </div>
                            </div>
                        </div>
                        <div id="staticinfocontainer" class="col-sm-6" style="text-align: left" runat="server">
                            <div class="jumbotron" style="text-align: left">
                                <h3>Visit Details</h3>
                                <label for="pInput">Visit Purpose</label>
                                <%--Check for Purpose of Visit--%>
                                <div class="form-group">
                                    <select class="form-control" id="pInput" onchange="purposePanels()" name="pInput">
                                        <option value="">-- Select One --</option>
                                        <option value="Visit Patient">Visit Patient</option>
                                        <option value="Other Purpose">Other Purpose</option>
                                    </select>
                                </div>
                                <div id="patientpurposevisit" class="container-fluid" runat="server">
                                    <%--Show this only when Visit Purpose is "Visit Patient"--%>
                                    <label for="patientName">Patient Name</label>
                                    <%--AJAX Call to search for Patient Name--%>
                                    <div class="form-group">
                                        <input type="text" runat="server" class="form-control" id="patientName" />
                                    </div>
                                    <label for="patientNric">Patient NRIC</label>
                                    <div class="form-group">
                                        <input type="text" runat="server" class="form-control" id="patientNric" />
                                    </div>
                                    <label for="bedno">Bed Number</label>
                                    <%--Bed Number--%>
                                    <div class="form-group">
                                        <input type="text" runat="server" class="form-control" id="bedno" />
                                    </div>
                                    <input type="button" id="validatePatientButton" value="Validate Patient Information" class="btn btn-warning" onclick="validatePatient(); false;" />
                                </div>
                                <div id="otherpurposevisit" class="container-fluid" runat="server">
                                    <%--Show this only when Visit Purpose is "Other Purpose"--%>
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
                                <div id="questionaireForm">
                                    <!-- load questionaires here -->
                                </div>
                                <div class="checkbox">
                                    <label for="declaration"></label>
                                    <input type="checkbox" id="declaration" name="declare" onchange="declarationValidation()" value="true" />I declare that the above information given is accurate<br />
                                    <input type="hidden" name="declare" value="false" />
                                    <label for="declaration" id="declabel" style="color: red">Please check this option to continue</label>
                                </div>
                                <input class="btn btn-success" type="submit" id="submitNewEntry" runat="server" onclick="checkRequiredFields(); false;" value="Submit" />
                            </div>
                        </div>
                    </div>
                
            </div>
            <!-- End of Registration -->

            <!-- FormManagement -->
            <div class="tab-pane maxHeight jumbotron" id="formManagement">
                <div class="row">
                    <div class="col-sm-6">
                        <div class="modal fade" id="addQuestionnaire" role="dialog">
    <div class="modal-dialog">
      <div class="modal-content">
        <div class="modal-header" style="padding:0px 50px;  text-align:center;">
         
          <h4>Add New Questionnaire</h4>
           
        </div>
        <div class="modal-body" style="padding:40px 50px; text-align:center;">
         
            <div class="form-group">
              <label for="qnaireid"><span class="glyphicon glyphicon-modal-window"></span> Questionnaire Name</label>
              <input type="text"  class="form-control" id="qnaireid" placeholder="Enter a Questionnaire ID"/>
            </div>
           
              <button type="button" class="btn btn-success btn-block" onclick="addQuestionnaire();"><span class="glyphicon glyphicon-plus"></span> Add Questionnaire</button>
          
        </div>
        <div class="modal-footer" style=" text-align:center !important;">
 <button type="submit" runat="server" class="btn btn-danger btn-default" onclick="hideAddQuestionnaireModal();">   <span class="glyphicon glyphicon-remove"></span> Cancel</button>        </div>
      </div>
      
    </div>
  </div> 
                        <h3>Select a Questionnaire to Begin</h3>
                            <div class="input-group" id="qnaireSelection">
                                    <select class="form-control" id="qnaires" onchange="getForm(); false;">
                                        <option value="">-- Select Questionnaire --</option>
                                        <option value="1">1</option>
                                        <option value="2">2</option>
                                    </select>
                                <span class="input-group-btn">
                                        <button class="btn btn-default" id="addQuestionnaireButton" onclick="showAddQuestionnaireModal();"><span class="glyphicon glyphicon-plus"></span> New Questionnaire</button>
                                </span>
                                    </div>
                        <div class="list-group" id="questionnaireQuestionsToDisplay">
                            <h3>Display Questionnaire #Number Questions Here</h3>
                            <h5>Each question will have a delete button next to it</h5>
                        </div>
                        </div>
                    <div class="col-sm-6">
                        <div class="list-group" id="questionnaireQuestions">
                            <h3>Display All Questions Here - Checkbox styled</h3>
                            <button type="button" id="addQuestionsToQuestionnaire" class="btn btn-success"><span class="glyphicon glyphicon-plus"></span> Add Questions to Questionnaire</button>
                        </div>
                        </div>
                    </div>
            </div>
            <!-- End of FormManagement -->

            <!-- TerminalManagement -->
            <div class="tab-pane maxHeight " style="position:relative" id="TerminalManagement">
                <div class="row inheritHeight">
                    <div class="col-md-8 col-md-offset-2 inheritHeight flexDisplay">
                        <div class="panel  panel-primary maxWidth overflowXaxis removeBtmMargin" >
                            <div class="panel-heading" style="font-size: 36px;">Terminals</div>
                            <div class="panel-body maxHeightWithButtonSpaceBelow">

                                <div class="modal fade" id="addTerminalModal" role="dialog">
                                    <div class="modal-dialog">

                                        <!-- Modal content-->
                                        <div class="modal-content">
                                            <div class="modal-header" style="padding: 0px 50px; text-align: center;">

                                                <h4>Add New Terminal </h4>

                                            </div>
                                            <div class="modal-body" style=" text-align: center;">

                                                <div class="form-group">
                                                   
                                                    <input type="text" class="form-control text-center" id="terminalNameInput" placeholder="Enter Terminal Name" />
                                                </div>

                                                <button type="button" class="btn btn-success btn-block" onclick="verifyUser();"><span class="glyphicon glyphicon-off"></span>Add New Terminal</button>

                                            </div>
                                            <div class="modal-footer" style="text-align: center !important;">
                                                <button type="button"   id="adminCloseTerminal"   class="btn btn-danger btn-default "><span class="glyphicon glyphicon-remove"></span>Cancel</button>
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


                            </div>
                            <div>
                                <button id="addTerminal" class="btn-primary btn-lg">Add Terminal</button>
                                <button id="deactivateTerminal" class="btn-primary btn-lg">Deactivate Selected Terminal</button>
                                <button id="deleteTerminal" class="btn-primary btn-lg">Delete Selected Terminal</button>
                                <button id="deactivateAll" class="btn-primary btn-lg">Deactivate All Terminals</button>
                            </div>
                        </div>
                    </div>
                </div>


            </div>
            <!-- End of TerminalManagement -->

            <!-- UserManagement -->
            <div class="tab-pane maxHeight" id="UserManagement">
                <h1>This is the test page FOR USERS potato pirates!</h1>


            </div>
            <!-- End of UserManagement -->

            <!-- PassManagement -->
            <div class="tab-pane maxHeight" id="PassManagement">
                <h1>This is the test page potato pirates!</h1>


            </div>
            <!-- End of PassManagement -->



        </div>
    </div>


    <script type="text/javascript" src="<%= Page.ResolveClientUrl("~/Webpage/Staff/TerminalCalls/adminTerminal.js") %>"></script>
    <script type="text/javascript" src="<%= Page.ResolveClientUrl("~/Webpage/Staff/QuestionaireManagement/loadQuestionaire.js") %>"></script>
    <script type="text/javascript" src="<%= Page.ResolveClientUrl("~/Scripts/fieldValidations.js") %>"></script>
    <script type="text/javascript" src="<%= Page.ResolveClientUrl("~/Webpage/Staff/registrationPageScripts.js") %>"></script>
    <script type="text/javascript">
        var user = '<%= Session["username"].ToString() %>';
    </script>
</body>
</html>
