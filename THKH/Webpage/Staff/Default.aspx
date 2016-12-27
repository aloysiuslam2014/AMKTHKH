<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Default.aspx.cs" Inherits="THKH.Webpage.Staff.Default" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <meta charset="utf-8" />
    <title>Welcome <%= Session["username"].ToString()%> | Ang Mo Kio - Thye Hwa Kuan</title>
    <link href="~/Content/bootstrap.min.css" rel="stylesheet" />
    <script type="text/javascript" src="<%= Page.ResolveClientUrl("~/Scripts/jquery-3.1.1.min.js") %>"></script>
    <script type="text/javascript" src="<%= Page.ResolveClientUrl("/Scripts/moment.min.js") %>"></script>
    <script type="text/javascript" src="<%= Page.ResolveClientUrl("/Scripts/jquery-ui.min.js") %>"></script>
    <script type="text/javascript" src="<%= Page.ResolveClientUrl("/Scripts/w3data.js") %>"></script>
    <script type="text/javascript" src="<%= Page.ResolveClientUrl("~/Scripts/bootstrap.min.js") %>"></script>
    <script type="text/javascript" src="<%= Page.ResolveClientUrl("/Scripts/bootstrap-datetimepicker.js") %>"></script>

    <link href="~/CSS/default.css" rel="stylesheet" />
    <link href="~/CSS/adminTerminal.css" rel="stylesheet" />
    <link href="~/CSS/formManagement.css" rel="stylesheet" />

     



</head>
<body onload="hideTags()">
    <% var accessRightsStr = Session["accessRights"].ToString(); %>
    <nav id="mainNav" class="navbar navbar-default navbar-fixed-top">
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
                    <%if (accessRightsStr.Contains('1'))
                        { %>
                    <li id="regtab" runat="server">
                        <a href="#registration" data-toggle="tab" onclick="hideTags(); false;">Registration
                        </a>
                    </li>
                    <%  }
                        if (accessRightsStr.Contains('2'))
                        {%>
                    <li>
                        <a href="#formManagement" data-toggle="tab" onclick="formManagementInit()">Form Management
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
                        <a href="#UserManagement" data-toggle="tab">User Management
                        </a>
                    </li>
                    <%  }
                        if (accessRightsStr.Contains('5'))
                        {%>
                    <li>
                        <a href="#PassManagement" data-toggle="tab">Pass Management
                        </a>
                    </li>
                    <%  }if (accessRightsStr.Contains('6')){%>
                    <li>
                        <a href="#ContactTracing" data-toggle="tab">Contact Tracing
                        </a>
                    </li>
                    <%  }%>
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
            <%if (accessRightsStr.Contains('1'))
                { %>
            <div class="tab-pane maxHeight" id="registration">

                <div class="row">
                    <div id="nurseInputArea" class="col-md-6 col-md-offset-3">
                        <div class="jumbotron" style="text-align: left">
                            <h3 style="color: midnightblue">Search for Visitor</h3>
                            <label class="control-label" for="nric">Visitor's NRIC:</label>
                            <div class="input-group date" id="nricinputgroup">
                                <input runat="server" id="nric" class="form-control required" type="text" autofocus />
                                <span class="input-group-btn">
                                    <button class="btn btn-warning" onclick="checkNricWarningDeclaration(); false;" runat="server"><span class="glyphicon glyphicon-search"></span> Check NRIC</button>
                                </span>
                            </div>
                            <h4 id="emptyNricWarning" style="color: red">Please enter your NRIC/Identification Number!</h4>
                            <div id="nricWarnDiv">
                                <h4 id="nricWarning" style="color: red">Non-Singapore Based NRIC/ID!</h4>
                                <div class="checkbox">
                                <label for="ignoreNric"></label>
                                <input type="checkbox" id="ignoreNric" name="declare" value="true" />Allow Anyway<br />
                                <label for="ignoreNric" id="ignoreNricLbl" style="color: red">Please check this option to continue</label>
                                </div>
                                </div>
                            <br />
                            <label class="control-label" for="temp">Temperature</label><label for="temp" id="comp0" style="color: red">*</label>
                            <input runat="server" id="temp" class="form-control required" type="text" onchange="checkTemp(); false;" />
                            <h4 id="tempWarning" style="color: red">Visitor's Temperature is above 37.6 Degrees Celcius!</h4>
                            <h4 id="invalidTempWarning" style="color: red">Please enter a valid temperature in the following format: "36.7"</h4>
                        </div>
                    </div>
                </div>
                <h4 id="emptyFields" style="color: red">Please fill in all the required fields (*).</h4>
                <div class="row">
                    <div id="newusercontent" class="col-sm-6" runat="server">
                        <div class="jumbotron" style="text-align: left">
                            <h3 style="color: midnightblue">Personal Details</h3>
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
                            <h3 style="color: midnightblue">Visit Details</h3>
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
                                <div class="form-group">
                                    <button id="validatePatientButton" value="Validate Patient Information" class="btn btn-warning" onclick="validatePatient(); false;"><span class="glyphicon glyphicon-check"></span>Validate Patient</button>
                                </div>
                            </div>
                            <div id="otherpurposevisit" class="container-fluid" runat="server">
                                <%--Show this only when Visit Purpose is "Other Purpose"--%>
                                <label for="visLoc">Intended Visit Location</label>
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
                            <%--Visit Date--%>
                            <label for="visitbookingdate">Intended Visit Date</label><label for="visitbookingdate" id="comp21" style="color: red">*</label>
                            <div class="input-group date" id="visitbookingdatediv">
                                <input type='text' id="visitbookingdate" class="form-control required" />
                                <span class="input-group-addon">
                                    <span class="glyphicon glyphicon-calendar"></span>
                                </span>
                            </div>
                            <%--Visit Time--%>
                            <label for="visitbookingtime">Intended Visit Time</label><label for="visitbookingtime" id="comp11" style="color: red">*</label>
                            <div class="input-group date" id="visitbookingtimediv">
                                <input type='text' id="visitbookingtime" class="form-control required" />
                                <span class="input-group-addon">
                                    <span class="glyphicon glyphicon-time"></span>
                                </span>
                            </div>
                            <h3 style="color: midnightblue">Health Screening Questionnaire</h3>
                            <div id="questionaireForm">
                                <!-- load questionaires here from JS -->
                            </div>
                            <div class="checkbox">
                                <label for="declaration"></label>
                                <input type="checkbox" id="declaration" name="declare" onchange="declarationValidation()" value="true" />I declare that the above information given is accurate<br />
                                <input type="hidden" name="declare" value="false" />
                                <label for="declaration" id="declabel" style="color: red">Please check this option to continue</label>
                            </div>
                            <button class="btn btn-success" id="submitNewEntry" onclick="checkRequiredFields(); false;"><span class="glyphicon glyphicon-list-alt"></span>Submit</button>
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
                    <div class="col-sm-6 panel" style="height: 95%;">
                        <div class="modal fade" id="addQuestionnaire" role="dialog">
                            <div class="modal-dialog">
                                <div class="modal-content">
                                    <div class="modal-header" style="padding: 0px 50px; text-align: center;">
                                        <h4 style="color: midnightblue">Add New Questionnaire</h4>
                                    </div>
                                    <div class="modal-body" style="padding: 40px 50px; text-align: center;">
                                        <div class="form-group">
                                            <input type="text" class="form-control" id="qnaireid" placeholder="Enter a Questionnaire Name" />
                                        </div>
                                        <button type="button" class="btn btn-success" onclick="newQuestionnaire();"><span class="glyphicon glyphicon-plus"></span> Add Questionnaire</button>
                                    </div>
                                    <div class="modal-footer" style="text-align: center !important;">
                                        <button type="submit" runat="server" class="btn btn-danger btn-default" onclick="hideAddQuestionnaireModal();"><span class="glyphicon glyphicon-remove"></span> Cancel</button>
                                    </div>
                                </div>
                            </div>
                        </div>
                        <h3 style="color: midnightblue">Select a Questionnaire to Begin</h3>
                        <div class="input-group" id="qnaireSelection">
                            <select class="form-control qnaire" id="qnaires" onchange="displayQuestionnaireQuestions(); false;">
                                <option value="">-- No Questionnaires Created --</option>

                            </select>
                            <span class="input-group-btn">
                                <button class="btn btn-primary" id="addQuestionnaireButton" onclick="showAddQuestionnaireModal();"><span class="glyphicon glyphicon-plus"></span> New Questionnaire</button>
                                <button class="btn btn-success" id="activeQuestionnaireButton" onclick="setActiveQuestionnaire(); false;"><span class="glyphicon glyphicon-star"></span> Set Active</button>
                            </span>
                        </div>
                        <div class="list-group" style="overflow: auto; height: 70%; border: solid 1pt; border-radius: 2px; margin-top: 3px;" id="questionnaireQuestionsToDisplay">
                            <%--Draggable Questions--%>
                            <ul class="list-group checked-list-box qnQns" id="sortable">
                                
                            </ul>
                        </div>
                        <div class="btn btn-group">
                            <button type="button"   onclick="selectAll('qnaire'); false;" class="btn btn-warning"><span class="glyphicon glyphicon-check"></span> Select All</button>
                            <button type="button"   onclick="deSelectAll('qnaire');false;" class="btn btn-warning"><span class="glyphicon glyphicon-unchecked"></span> Unselect All</button>
                        </div><br />
                        <div class="btn btn-group">
                            <button type="button" id="delQuestionsFromQuestionnaire" onclick="removeQFromQuestionnaire(); false;" class="btn btn-danger"><span class="glyphicon glyphicon-trash"></span> Remove Questions</button>
                            <button type="submit" id="saveQuestionnaireChangesButton" onclick="updateQuestionnaire(); false;" class="btn btn-success"><span class="glyphicon glyphicon-ok"></span> Update Questionnaire</button>
                        </div>
                    </div>

                    <!-- questions to be added portion -->
                    <div class="col-sm-6 panel" style="height: 95%;">
                        <div class="list-group" style="height: 94%;" id="questionnaireQuestions">
                            <h3 style="color: midnightblue">Available Question(s)</h3>
                            <%--Checkbox Questions--%>
                            <div class="input-group" id="searchQns">
                            <input type="text" class="form-control maxWidth" placeholder="Enter term to search in question list..." onkeyup="filterCurrentList(this)"/>
                            <span class="input-group-btn">
                            <button type="button" id="createNewQuestion" data-toggle="collapse" data-target="#qnEditor" onclick="clearQnEditorFields(); false;" class="btn btn-success"><span class="glyphicon glyphicon-plus"></span> Create New Question</button>
                            </span>
                                </div>
                                <div class=" " style="border: solid 1pt; border-radius: 2px; height: 75%; overflow-y: auto;margin-top:2px;">
                                    <div id="cover" style="background-color:grey;opacity:0.5;margin-top: 93px;width: 100%;height:inherit; padding-right:30px;position:absolute"></div>
                                   
                                <ul class="list-group checked-list-box maxHeight" id="allQuestions" style="">
                                    
                                </ul>
                                     <div id="qnEditor" class="panel-collapse collapse placeAboveOtherDivs" style="margin-top: 93px;width: 100%;height:inherit; padding-right:30px">
                                          <div class="panel-body questionEditor" style="background-color: ivory;border-style: solid;border-width: 1px;">
                                              <h3 id="editQuestionTitle">Question Details</h3>
                                              <div>Question:<textarea  id="detailsQn" rows="3" cols="30">  </textarea></div>
                                              <div>Question Response Type: <input type="text" id="detailsQnType" /></div>
                                              <div>Question Value: <input type="text" id="detailsQnValues" /></div>
                                              <button type="button" data-toggle="collapse" data-target="#qnEditor" id="closeQnEditor" onclick="clearQnEditorFields(); false;" class="btn btn-danger"><span class="glyphicon glyphicon-trash"></span> Close</button>
                                              <button type="button" id="updateOrCreateQn"   onclick="updateOrCreate(); false;" class="btn btn-success"><span class="glyphicon glyphicon-file"></span> Save Question</button>

                                          </div>
                                     </div>
                            </div>
                           
                            <div class="btn btn-group">
                                <button type="button" id="selectAll" onclick="selectAll('qns'); false;" class="btn btn-warning"><span class="glyphicon glyphicon-check"></span> Select All</button>
                                <button type="button" id="deSelectAll" onclick="deSelectAll('qns');false;" class="btn btn-warning"><span class="glyphicon glyphicon-unchecked"></span> Unselect All</button>
                            </div><br />
                            <div class="btn btn-group">
                                <button type="button" id="addQuestionsToQuestionnaire" onclick="AddQtoQuestionnaire(); false;" class="btn btn-success"><span class="glyphicon glyphicon-plus"></span> Add to Questionnaire</button>                           
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
                            <div class="panel-body maxHeightWithButtonSpaceBelow">

                                <div class="modal fade" id="addTerminalModal" role="dialog">
                                    <div class="modal-dialog">

                                        <!-- Modal content-->
                                        <div class="modal-content">
                                            <div class="modal-header" style="padding: 0px 50px; text-align: center;">

                                                <h4>Add New Terminal </h4>

                                            </div>
                                            <div class="modal-body" style="text-align: center;">

                                                <div class="form-group">

                                                    <input type="text" class="form-control text-center" id="terminalNameInput" placeholder="Enter Terminal Name" />
                                                </div>

                                                <button type="button" class="btn btn-success btn-block" id="addNewTerminal"><span class="glyphicon glyphicon-off"></span>Add New Terminal</button>

                                            </div>
                                            <div class="modal-footer" style="text-align: center !important;">
                                                <button type="button" id="adminCloseTerminal" class="btn btn-danger btn-default "><span class="glyphicon glyphicon-remove"></span>Cancel</button>
                                            </div>
                                        </div>

                                    </div>
                                </div>
                                <div class="modal fade" id="promptTerminalModal" role="dialog">
                                    <div class="modal-dialog">

                                        <!-- Modal content-->
                                        <div class="modal-content">

                                            <div class="modal-body" id="prompText" style="text-align: center;">

                                                <h2>Successfully Added New Terminal</h2>

                                            </div>
                                            <div class="modal-footer" style="text-align: center !important;">
                                                <button type="button" id="closeAllTerminal" class="btn btn-danger btn-default "><span class="glyphicon glyphicon-remove"></span>Close</button>
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
                                                <button type="button" id="confirmAction" class="btn bg-primary btn-default "><span class="glyphicon glyphicon-save-file"></span>Confirm</button>
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


                            </div>
                            <div>
                                <button id="addTerminal" class="btn-primary btn-lg">Add Terminal</button>
                                <button id="deactivateTerminal" class="btn-primary btn-lg">Deactivate Selected Terminal</button>
                                <button id="deleteTerminal" class="btn-primary btn-lg">Delete Selected Terminal</button>

                            </div>
                            <div>
                                <button id="deactivateAll" class="btn-primary btn-lg">Deactivate All Terminals</button>
                                <button id="deleteAll" class="btn-primary btn-lg">Delete All Terminals</button>
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
                <div class="row inheritHeight">
                    <div class="col-sm-4 panel inheritHeight">
                        <h3 style="color: midnightblue">Existing Users</h3>
                        <div class="input-group" id="searchUser">
                            <input type="text" class="form-control maxWidth" placeholder="Search Name" onkeyup="filterCurrentList(this)"/>
                            <span class="input-group-btn">
                                <button type="button" id="" onclick="selectAllUsers(); false;" class="btn btn-warning"><span class="glyphicon glyphicon-check"></span> Select All</button>
                                <button type="button" id="" onclick="deSelectAllUsers();false;" class="btn btn-warning"><span class="glyphicon glyphicon-unchecked"></span> Unselect All</button>
                            </span>
                                </div>
                          
                            <div class=" " style="border: solid 1pt; border-radius: 2px; height: 74%; overflow-y: auto;margin-top:2px;">
                                <ul class="list-group checked-list-box maxHeight" id="usersLis" style="">
                                    <li class="list-group-item" id="">user 1</li>
                                </ul>
                            </div>
                            <div>
                                <button type="button" id="" onclick="selectAllUsers(); false;" class="btn btn-danger"><span class="glyphicon glyphicon-ban-circle"></span> Delete Selected User(s)</button>
                            </div>
                         
                       
                    </div>
                    <div>
                     Display Staff Information  
                    </div>
                </div>
            </div>
            <%}
                if (accessRightsStr.Contains('5'))
                { %>
            <!-- End of UserManagement -->

            <!-- PassManagement -->
            <div class="tab-pane maxHeight" id="PassManagement">
                <h1>This is the test page potato pirates!</h1>


            </div>
            <!-- End of PassManagement -->

            <%}
                if (accessRightsStr.Contains('6'))
                { %>
            <!-- ContactTracing -->
            <div class="tab-pane maxHeight" id="ContactTracing">
                <h1>This is the test page potato pirates!</h1>


            </div> 
            <!-- End of ContactTracing -->
            <%} %>
        </div>
    </div>

    <script type="text/javascript" src="<%= Page.ResolveClientUrl("~/Webpage/Staff/default.js") %>"></script>
    <script type="text/javascript" src="<%= Page.ResolveClientUrl("~/Webpage/Staff/TerminalCalls/adminTerminal.js") %>"></script>
    <script type="text/javascript" src="<%= Page.ResolveClientUrl("~/Webpage/Staff/QuestionaireManagement/loadQuestionaire.js") %>"></script>
    <script type="text/javascript" src="<%= Page.ResolveClientUrl("~/Scripts/fieldValidations.js") %>"></script>
    <script type="text/javascript" src="<%= Page.ResolveClientUrl("~/Webpage/Staff/registrationPageScripts.js") %>"></script>
    <script type="text/javascript">
        var user = '<%= Session["username"].ToString() %>';
    </script>
</body>
</html>
