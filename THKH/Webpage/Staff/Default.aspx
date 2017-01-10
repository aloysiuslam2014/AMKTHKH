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
    <link href="~/CSS/passManagement.css" rel="stylesheet" />





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
                        <a href="#PassManagement" data-toggle="tab">Pass Management
                        </a>
                    </li>
                    <%  }
                    if (accessRightsStr.Contains('6'))
                    {%>
                    <li>
                        <a href="#ContactTracing" data-toggle="tab">Contact Tracing
                        </a>
                    </li>
                    <%  }%>
                </ul>

               
                        <form id="logbtn" class="nav navbar-nav navbar-right" style="margin-top: 10px;" runat="server">
                            <div>
                                <label>Welcome, <%= Session["username"].ToString()%></label>
                                <asp:Button ID="logout" class="btn btn-danger" Text="logout" OnClick="logout_Click" runat="server" />
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
                <a data-controls-modal="successModal" data-backdrop="static" data-keyboard="false" href="#/"></a>
                <div class="modal fade" id="successModal" tabindex="-1" role="dialog" aria-labelledby="memberModalLabel" aria-hidden="true">
                    <div class="modal-dialog">
                        <div class="modal-content">
                            <div class="modal-header text-center">
                                <img src="../../Assets/hospitalLogo.png" class="img img-responsive" /><br />
                                <h4 class="modal-title" id="memberModalLabel1" style="color:midnightblue">Registration Successful</h4>
                            </div>
                            <div class="modal-body text-center">
                                    <label>Visit data recorded at <%=DateTime.Now %>.</label>
                                    <label style="color:green">Visitor has been checked in!</label>
                            </div>
                            <div class="modal-footer">
                                <button class="btn btn-block btn-danger" id="closeSuccessButton" onclick="hideSuccessModal(); false;"><span class="glyphicon glyphicon-off"></span> Close</button>
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
                                <button class="btn btn-block btn-danger" id="closeMaxLimitButton" onclick="hideMaxLimitModal(); false;"><span class="glyphicon glyphicon-off"></span> Close</button>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="row">
                    <div id="nurseInputArea" class="col-md-6 col-md-offset-3">
                        <div class="jumbotron" style="text-align: left">
                            <h3 style="">Search for Visitor</h3>
                            <label class="control-label" for="nric">Visitor's NRIC:</label>
                            <div class="input-group date" id="nricinputgroup">
                                <input runat="server" id="nric" class="form-control required regInput" type="text" autofocus />
                                <span class="input-group-btn">
                                    <button class="btn btn-warning" id="checkNricButton" onclick="checkNricWarningDeclaration(); false;" runat="server"><span class="glyphicon glyphicon-search"></span> Check NRIC</button>
                                </span>
                            </div>
                            <h4 id="emptyNricWarning" style="color: red">Please enter your NRIC/Identification Number!</h4>
                            <div id="nricWarnDiv">
                                <h4 id="nricWarning" style="color: red">Non-Singapore Based NRIC/ID!</h4>
                                <div class="checkbox">
                                    <label for="ignoreNric"></label>
                                    <input type="checkbox" id="ignoreNric" name="declare" value="true" class="regInput" />Allow Anyway<br />
                                    <label for="ignoreNric" id="ignoreNricLbl" style="color: red">Please check this option to continue</label>
                                </div>
                            </div>
                            <br />
                            <label class="control-label" for="temp">Temperature</label><label for="temp" id="comp0" style="color: red">*</label>
                            <input runat="server" id="temp" class="form-control required regInput" type="text" />
                            <h4 id="tempWarning" style="color: red">Visitor's Temperature is above 37.6 Degrees Celcius!</h4>
                            <h4 id="invalidTempWarning" style="color: red">Please enter a valid temperature in the following format: "36.7"</h4>
                        </div>
                    </div>
                </div>

                <div class="row">
                    <div id="newusercontent" class="col-sm-6" runat="server">
                        <div class="jumbotron" style="text-align: left">
                            <h3 style="">Personal Details</h3>
                            <label for="namesinput">Full Name</label><label for="namesinput" id="comp1" style="color: red">*</label>
                            <div class="form-group">
                                <input type="text" runat="server" class="form-control required regInput" id="namesInput" />
                            </div>
                            <label for="emailinput">Email address</label>
                            <div class="form-group">
                                <input type="text" runat="server" class="form-control regInput" id="emailsInput" />
                            </div>
                            <label for="mobileinput">Mobile Number</label><label for="namesinput" id="comp12" style="color: red">*</label>
                            <div class="form-group">
                                <input type="text" runat="server" class="form-control required regInput" id="mobilesInput" />
                                <label for="mobilesInput" id="mobWarning" style="color: red">Invalid Phone Number Format!</label>
                            </div>
                            <label for="homeinput">Home Number</label>
                            <div class="form-group">
                                <input type="text" runat="server" class="form-control regInput" id="homesInput" />
                                <label for="homesInput" id="homeWarning" style="color: red">Invalid Phone Number Format!</label>
                            </div>
                            <label for="altInput">Alternate Number</label>
                            <div class="form-group">
                                <input type="text" runat="server" class="form-control regInput" id="altInput" />
                                <label for="altInput" id="altWarning" style="color: red">Invalid Phone Number Format!</label>
                            </div>
                            <label for="addressinput">Address</label><label for="addressinput" id="comp2" style="color: red">*</label>
                            <div class="form-group">
                                <input type="text" runat="server" class="form-control required regInput" id="addresssInput" />
                            </div>
                            <label for="postalinput">Postal Code</label><label for="postalinput" id="comp3" style="color: red">*</label>
                            <div class="form-group">
                                <input type="text" runat="server" class="form-control required regInput" id="postalsInput" />
                                <label for="postalsInput" id="posWarning" style="color: red">Invalid Postal Code Format!</label>
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
                                <select class="form-control required regInput" onchange="checkNationals(); false;" id="nationalsInput">
                                    <option value="">-- Select One --</option>
                                </select>
                                <label for="nationalsInput" id="natWarning" style="color: red">Please select a nationality!</label>
                            </div>
                            <label for="daterange">Date of Birth</label><label for="daterange" id="comp6" style="color: red">*</label>
                            <div class="input-group date" id="datetimepicker">
                                <input type='text' id="daterange" class="form-control required regInput" />
                                <span class="input-group-addon">
                                    <span class="glyphicon glyphicon-calendar"></span>
                                </span>
                            </div>
                        </div>
                    </div>
                    <div id="staticinfocontainer" class="col-sm-6" style="text-align: left" runat="server">
                        <div class="jumbotron" style="text-align: left">
                            <h3 style="">Visit Details</h3>
                            <label for="pInput">Visit Purpose</label><label for="pInput" id="comp69" style="color: red">*</label>
                            <%--Check for Purpose of Visit--%>
                            <div class="form-group">
                                <select class="form-control required regInput" id="pInput" onchange="purposePanels()" name="pInput">
                                    <option value="">-- Select One --</option>
                                    <option value="Visit Patient">Visit Patient</option>
                                    <option value="Other Purpose">Other Purpose</option>
                                </select>
                                <label for="pInput" id="purWarning" style="color: red">Please select a Visit Purpose!</label>
                            </div>
                            <div id="patientpurposevisit" class="container-fluid" runat="server">
                                <%--Show this only when Visit Purpose is "Visit Patient"--%>
                                <label for="patientName">Patient Name</label>
                                <div class="form-group">
                                    <input type="text" runat="server" class="form-control regInput" id="patientName" />
                                </div>
                                <label for="bedno">Bed Number</label>
                                <%--Bed Number--%>
                                <div class="form-group">
                                    <input type="text" runat="server" class="form-control regInput" id="bedno" />
                                </div>
                                <label for="patientNric">Patient NRIC</label>
                                <div class="form-group">
                                    <input type="text" runat="server" class="form-control regInput" id="patientNric" />
                                </div>
                                <label></label>
                                <div class="form-group">
                                    <button id="validatePatientButton" value="Validate Patient Information" class="btn btn-warning" onclick="validatePatient(); false;"><span class="glyphicon glyphicon-check"></span>Validate Patient</button>
                                    <label for="validatePatientButton" id="patientStatusGreen" style="color: green">Patient Found!</label>
                                    <label for="validatePatientButton" id="patientStatusRed" style="color: red">Patient Not Found!</label>
                                </div>
                            </div>
                            <div id="otherpurposevisit" class="container-fluid" runat="server">
                                <%--Show this only when Visit Purpose is "Other Purpose"--%>
                                <label for="visLoc">Intended Visit Location</label>
                                <div class="form-group">
                                    <select class="form-control" id="visLoc">
                                        <option value="">-- Select One --</option>
                                    </select>
                                </div>
                                <label for="purposeInput">Purpose of Visit</label>
                                <div class="form-group">
                                    <input type="text" runat="server" class="form-control regInput" id="purposeInput" />
                                </div>
                            </div>
                            <%--Visit Date--%>
                            <label for="visitbookingdate">Intended Visit Date</label><label for="visitbookingdate" id="comp21" style="color: red">*</label>
                            <div class="input-group date" id="visitbookingdatediv">
                                <input type='text' id="visitbookingdate" class="form-control required regInput" />
                                <span class="input-group-addon">
                                    <span class="glyphicon glyphicon-calendar"></span>
                                </span>
                            </div>
                            <%--Visit Time--%>
                            <label for="visitbookingtime">Intended Visit Time</label><label for="visitbookingtime" id="comp11" style="color: red">*</label>
                            <div class="input-group date" id="visitbookingtimediv">
                                <input type='text' id="visitbookingtime" class="form-control required regInput" />
                                <span class="input-group-addon">
                                    <span class="glyphicon glyphicon-time"></span>
                                </span>
                            </div>
                            <h3 style="">Health Screening Questionnaire</h3>
                            <div id="questionaireForm">
                                <!-- load questionaires here from JS -->
                            </div>
                            <div class="checkbox">
                                <label for="declaration"></label>
                                <input type="checkbox" id="declaration" name="declare" class="regInput" onchange="declarationValidation()" value="true" />I declare that the above information given is accurate<br />
                                <input type="hidden" name="declare" value="false" />
                                <label for="declaration" id="declabel" style="color: red">Please check this option to continue</label>
                            </div>
                            <h4 id="emptyFields" style="color: red">Please fill in all the required fields with valid data (*) highlighted in yellow.</h4>
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
                    <div class="col-sm-6 panel"  style="height: 100%;margin-bottom:0">
                        <div class="modal fade" id="addQuestionnaire" role="dialog">
                            <div class="modal-dialog">
                                <div class="modal-content">
                                    <div class="modal-header" style="padding: 0px 50px; text-align: center;">
                                        <img src="../../Assets/hospitalLogo.png" class="img img-responsive" /><br />
                                        <h4 style="">Add New Questionnaire</h4>
                                    </div>
                                    <div class="modal-body" style="padding: 40px 50px; text-align: center;">
                                        <div class="input-group">
                                          <span class="input-group-addon" id="basic-addon">Questionnaire Name</span>
                                          <input type="text" class="form-control" id="qnaireid" aria-describedby="basic-addon" />      
                                        </div>
                                        <label id="emptyQuestionnaireWarning" style="color:red">Please enter a questionnaire name!</label>
                                            <label id="questionnaireWarning" style="color:red">Questionnaire name already exists! Please use a unique name.</label>
                                        </div>
                                    <div class="modal-footer" style="text-align: center !important;">
                                        <button type="submit" runat="server" class="btn btn-danger btn-default" onclick="hideAddQuestionnaireModal();"><span class="glyphicon glyphicon-remove"></span>Cancel</button>
                                    <button type="button" class="btn btn-success" onclick="newQuestionnaire();"><span class="glyphicon glyphicon-plus"></span>Add Questionnaire</button>
                                    </div>
                                </div>
                            </div>
                        </div>
                        <h3 style="">Select a Questionnaire to Begin</h3>
                        <div class="input-group" id="qnaireSelection">
                            <select class="form-control qnaire" id="qnaires" onchange="displayQuestionnaireQuestions(); false;">
                                <option value="">-- No Questionnaires Created --</option>

                            </select>
                            <span class="input-group-btn">
                                <button class="btn btn-primary" id="addQuestionnaireButton" onclick="showAddQuestionnaireModal();"><span class="glyphicon glyphicon-plus"></span>New Questionnaire</button>
                                <button class="btn btn-success" id="activeQuestionnaireButton" onclick="setActiveQuestionnaire(); false;"><span class="glyphicon glyphicon-star"></span>Set Active</button>
                            </span>
                        </div>
                        <div class="list-group" style="overflow: auto; height: 70%; border: solid 1pt; border-radius: 2px; margin-top: 3px;" id="questionnaireQuestionsToDisplay">
                            <%--Draggable Questions--%>
                            <ul class="list-group checked-list-box qnQns" id="sortable">
                            </ul>
                        </div>
                        <div class=" btn-group">
                            <button type="button" onclick="selectAll('qnaire'); false;" class="btn btn-warning"><span class="glyphicon glyphicon-check"></span>Select All</button>
                            <button type="button" onclick="deSelectAll('qnaire');false;" class="btn btn-warning"><span class="glyphicon glyphicon-unchecked"></span>Unselect All</button>
                        </div>
                        <br />
                        <div class=" btn-group">
                            <button type="button" id="delQuestionsFromQuestionnaire" onclick="removeQFromQuestionnaire(); false;" class="btn btn-danger"><span class="glyphicon glyphicon-trash"></span>Remove Questions</button>
                            <button type="submit" id="saveQuestionnaireChangesButton" onclick="updateQuestionnaire(); false;" class="btn btn-success"><span class="glyphicon glyphicon-ok"></span>Update Questionnaire</button>
                        </div>
                        <div class="modal fade" id="updateQuestionnaireSuccess" role="dialog">
                                    <div class="modal-dialog">

                                        <!-- Modal content-->
                                        <div class="modal-content">
                                            <div class="modal-header" style="padding: 0px 50px; text-align: center;">
                                                <img src="../../Assets/hospitalLogo.png" class="img img-responsive" /><br />
                                                <h4 style="color:midnightblue">Success</h4>

                                            </div>
                                            <div class="modal-body" style="text-align: center;">
                                                <label style="color:green">Questionnaire Updated!</label>
                                            </div>
                                            <div class="modal-footer" style="text-align: center !important;">
                                                <button type="button" id="closeUpdateQuestionnaire" onclick="closeUpdateSuccess(); false;" class="btn btn-danger"><span class="glyphicon glyphicon-remove"></span>Close</button>
                                            </div>
                                        </div>

                                    </div>
                                </div>
                        <div class="modal fade" id="setActiveSuccess" role="dialog">
                                    <div class="modal-dialog">

                                        <!-- Modal content-->
                                        <div class="modal-content">
                                            <div class="modal-header" style="padding: 0px 50px; text-align: center;">
                                                <img src="../../Assets/hospitalLogo.png" class="img img-responsive" /><br />
                                                <h4 style="color:midnightblue">Success</h4>
                                            </div>
                                            <div class="modal-body" style="text-align: center;">
                                                <label style="color:green">Questionnaire set as Active!</label>
                                            </div>
                                            <div class="modal-footer" style="text-align: center !important;">
                                                <button type="button" id="closeActiveSuccess" onclick="closeActiveSuccess(); false;" class="btn btn-danger"><span class="glyphicon glyphicon-remove"></span>Close</button>
                                            </div>
                                        </div>

                                    </div>
                                </div>
                        <div class="modal fade" id="addQuestionnaireSuccess" role="dialog">
                                    <div class="modal-dialog">

                                        <!-- Modal content-->
                                        <div class="modal-content">
                                            <div class="modal-header" style="padding: 0px 50px; text-align: center;">
                                                <img src="../../Assets/hospitalLogo.png" class="img img-responsive" /><br />
                                                <h4 style="color:midnightblue">Success</h4>

                                            </div>
                                            <div class="modal-body" style="text-align: center;">
                                                <label style="color:green">Questionnaire Added!</label>
                                            </div>
                                            <div class="modal-footer" style="text-align: center !important;">
                                                <button type="button" id="closeAddQuestionnaireSuccess" onclick="closeAddQuestionnaireSuccess(); false;" class="btn btn-danger"><span class="glyphicon glyphicon-remove"></span>Close</button>
                                            </div>
                                        </div>

                                    </div>
                                </div>
                    </div>

                    <!-- questions to be added portion -->
                    <div class="col-sm-6 panel" style="height: 100%;margin-bottom:0">
                        <div class="list-group" style="height: 94%;" id="questionnaireQuestions">
                            <h3 style="">Available Question(s)</h3>
                            <%--Checkbox Questions--%>
                            <div class="input-group" id="searchQns">
                                <input type="text" class="form-control maxWidth" placeholder="Enter term to search in question list..." onkeyup="filterCurrentList(this)" />
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
                                <div id="qnEditor" class="panel-collapse collapse placeAboveOtherDivs" style="margin-top: 93px; width: 100%; height: inherit; padding-right: 30px;">
                                    <div class="panel-body questionEditor" style="background-color: #343637; border-style: solid; border-width: 1px;">
                                        <h3 id="editQuestionTitle">Question Details</h3>
                                        <div>Question<textarea id="detailsQn" class="form-control qnVal" rows="3" cols="80">  </textarea></div>
                                        <div>
                                            Question Response Type
                                            <select id="detailsQnType" class="form-control qnVal">
                                                <option value="" selected="selected">-- Select a type --</option>
                                                <option value="ddList">Drop-down list</option>
                                                <option value="checkbox">Checkbox</option>
                                                <option value="radio">Radio Button</option>
                                                <option value="text">Text Field</option>
                                            </select>
                                        </div>
                                        <div>
                                            Question Values
                                            <textarea id="detailsQnValues" class="form-control qnVal" rows="2" cols="60"></textarea>
                                        </div><br />
                                        <button type="button" data-toggle="collapse" data-target="#qnEditor" id="closeQnEditor" onclick="closeEditor(); false;" class="btn btn-danger"><span class="glyphicon glyphicon-trash"></span> Close</button>
                                        <button type="button" id="updateOrCreateQn" onclick="updateOrCreate(); false;" class="btn btn-success"><span class="glyphicon glyphicon-file"></span> Save Question</button>
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
                                <button type="button" id="addQuestionsToQuestionnaire" onclick="AddQtoQuestionnaire(); false;" class="btn btn-success"><span class="glyphicon glyphicon-plus"></span>Add to Questionnaire</button>
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
                                                <img src="../../Assets/hospitalLogo.png" class="img img-responsive" /><br />
                                                <h4 style="color:midnightblue">Add New Terminal </h4>

                                            </div>
                                            <div class="modal-body" style="text-align: center;">

                                                <div class="form-group">
                                                    <label>Terminal Name</label>
                                                    <input type="text" class="form-control text-center" id="terminalNameInput" placeholder="Enter Terminal Name" />
                                                    <label>Bed's attached to Terminal</label>
                                                    <input type="text" class="form-control text-center" id="beds" placeholder="Enter Bed Numbers seperated by comma" />
                                                    <label>Terminal in an infectious location?</label>
                                                    <select id="terminalInfectious">
                                                        <option value="Yes">Yes</option>
                                                        <option value="No">No</option>
                                                    </select>
                                                </div>

                                                

                                            </div>
                                            <div class="modal-footer" style="text-align: center !important;">
                                                <button type="button" id="adminCloseTerminal" class="btn btn-danger btn-default "><span class="glyphicon glyphicon-remove"></span> Cancel</button>
                                            <button type="button" class="btn btn-success" id="addNewTerminal"><span class="glyphicon glyphicon-off"></span> Add New Terminal</button>
                                            </div>
                                        </div>

                                    </div>
                                </div>
                                <div class="modal fade" id="promptTerminalModal" role="dialog">
                                    <div class="modal-dialog">

                                        <!-- Modal content-->
                                        <div class="modal-content">

                                            <div class="modal-body" id="prompText" style="text-align: center;">

                                                <label style="color:green">Successfully Added New Terminal</label>

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
                    <div class="col-sm-4 inheritHeight">
                        <h3 style="">Existing Users</h3>
                        <div class="input-group" id="searchUser">
                            <input type="text" class="form-control maxWidth" placeholder="Search Name" onkeyup="filterUserList(this)" />
                            <span class="input-group-btn">
                                <button type="button" id="" onclick="selectAllUsers(); false;" class="btn btn-warning"><span class="glyphicon glyphicon-check"></span>Select All</button>
                                <button type="button" id="" onclick="deSelectAllUsers();false;" class="btn btn-warning"><span class="glyphicon glyphicon-unchecked"></span>Unselect All</button>
                            </span>
                        </div>

                        <div class=" " style="border: solid 1pt;margin-bottom: 25px; border-radius: 2px; height: 77%; overflow-y: auto; margin-top: 2px;">
                            <ul class="list-group checked-list-box maxHeight" id="usersLis" style="">
                                
                            </ul>
                        </div>
                        <div>
                            <button type="button" id="" onclick="selectAllUsers(); false;" class="btn btn-danger"><span class="glyphicon glyphicon-ban-circle"></span>Delete Selected User(s)</button>
                        </div>
                    </div>

                    <div class="col-sm-8 row" style="overflow-y: auto">
                        <h2 id="userMode">Create New User</h2>
                        <h3 style="margin-top: 0;margin-bottom: 0;">User details</h3>
                        <div>
                            <div class="col-md-6">
                                <label>Email</label>
                                <div class="form-group">
                                    <input id="staffEmail" class="form-control" /></div>
                                <label>First Name</label>
                                <div class="form-group">
                                    <input id="staffFirstName" class="form-control" /></div>
                                <label>Last Name</label>
                                <div class="form-group">
                                    <input id="staffLastName" class="form-control" /></div>
                                <label>NRIC</label>
                                <div class="form-group">
                                    <input id="staffNric" class="form-control" /></div>
                                <label>Address</label>
                                <div class="form-group">
                                    <input id="staffAddress" class="form-control" /></div>
                                <label>Postal Code</label>
                                <div class="form-group">
                                    <input id="staffPostal" class="form-control" /></div>
                                <label>Contact Number(Mobile)</label>
                                <div class="form-group">
                                    <input id="staffMobileNum" class="form-control" /></div>
                                <label>Contact Number(Home)</label>
                                <div class="form-group">
                                    <input id="staffHomeNum" class="form-control" /></div>
                                </div>
                            <div class="col-md-6">
                                <label>Contact Number(Alt)</label>
                                <div class="form-group">
                                    <input id="staffAltNum" class="form-control" /></div>
                                <label>Sex</label>
                                <div class="form-group">
                                    <select id="staffSex" class="form-control">
                                        <option value="M">Male</option>
                                        <option value="F">Female</option>
                                    </select>
                                </div>
                                <label>Nationality</label>
                                <div class="form-group">
                                    <input id="staffNationality" class="form-control" /></div>
                                <label>Date Of Birth</label>
                                <div class="form-group">
                                    <input id="staffDOB" class="form-control" /></div>
                                <label>Age</label>
                                <div class="form-group">
                                    <input id="staffAge" class="form-control" /></div>
                                <label>Race</label>
                                <div class="form-group">
                                    <input id="staffRace" class="form-control" /></div>
                                <label>Position Title</label>
                                <div class="form-group">
                                    <input id="staffTitle" class="form-control" /></div>
                                <label>Permission</label>
                                <div class="form-group">
                                    <input id="staffPerms" class="form-control" /></div>
                            </div>
                        </div>
                        
                        <div class="btn-group">   
                                        
                            <button type="button"  class="btn btn-warning" onclick="prepareForNewUser();">Create New User/Clear All Fields</button>
                            <button type="button" class="btn btn-success" onclick="saveUser();">Save</button>
                            
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
                            <h3 style="margin:0">Edit Pass Settings </h3>
                        </div>
                        <div class="panel-body">
                         <div class="row">
                               <h3 style="margin: 0;">Select Size of pass:</h3>
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
                                <h3 style="margin-top: 0;">Add Text</h3>
                                Source of the text to be displayed:
                                <br />
                                  <select id="source" class="form-control" style="width: 50%;margin: auto;" onchange="ifCustom();">

                                      <option value="First Name">First Name</option>
                                      <option value="Last Name">Last Name</option>
                                      <option value="Mobile Number">Mobile Number</option>
                                      <option value="Date Of Birth">Date Of Birth</option>
                                      <option value=""></option>
                                      <option value="custom">Custom Text</option>
                                  </select>
                                <input type="text" id="customText" placeholder="Custom Text Here" class="text-center" style="display:none" />
                                <br />
                                <button type="button" class="btn btn-success " id="addText"  onclick="addTextToPass();">Add Text</button>
                            </div>
                            <hr />
                            <div class="row">
                                <h3 style="margin-top: 0;">Add Barcode</h3>
                                <button type="button" class="btn btn-primary"  id="addBarcode" onclick="addBarCodeToPassLayout()">Add Barcode</button>
                            </div>
                            <hr />
                            <div>
                                <h3 style="margin-top: 0;">Add Image</h3>
                                <button type="button" class="btn btn-primary" id="addBgImg" onclick="$('#imageUpload').click();">Add Image</button>
                                <input type="file" id="imageUpload" onchange="createImageAndAdd(this)" class="hidden"/>
                            </div>

                        </div>
                    </div>
                    <div id="sampleOutput" class="col-sm-8 row inheritHeight panel" style="background-color: initial">
                        <div class="panel-heading">
                            <h3 style="margin:0">Sample Pass Output</h3>
                        </div>
                        <div class= " panel-body vertical-center center-block " style="background-color:darkslategray;overflow-y:auto;text-align: center; height: 93%;">
                            <div id="passLayout" class=" " style="background-color:white;border:1px solid ;height: 50.8mm; width: 89mm;margin:auto">
                                
                            </div>
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
         <div class="row inheritHeight">
             <!-- query input portion -->
             <div class="col-sm-6 panel" style="height: 95%;">
                 <h3 style="">Build Queries</h3>
                 <div class="form-group">

                     <div class="col-sm-4">
                         <div class="input-group date" id="querystartdatetime">
                             <input type='text' id="qstartdatetime" class="form-control required" placeholder="Start DateTime"/>
                             <span class="input-group-addon">
                                 <span class="glyphicon glyphicon-calendar"></span>
                             </span>
                         </div>
                     </div>

                     <div class="col-sm-4">
                         <div class="input-group date" id="queryenddatetime">
                             <input type='text' id="qenddatetime" class="form-control required" placeholder="End DateTime" />
                             <span class="input-group-addon">
                                 <span class="glyphicon glyphicon-calendar"></span>
                             </span>
                         </div>
                    </div>
                         
                     <script type="text/javascript">
                         $(function () {
                             $('#querystartdatetime').datetimepicker();
                         });
                         $(function () {
                             $('#queryenddatetime').datetimepicker();
                         });
                     </script>
                
                     <div class="input-group col-sm-4" id="querybedrange">
                         <input type="text" class="form-control" id="querybeds" placeholder="Beds: 1-4,7,10 " />
                         <span class="input-group-btn">
                             <button class="btn btn-primary" id="addDateTimeRange" onclick="addDateTimeRange();"><span class="glyphicon glyphicon-plus"></span>Add Query</button>
                         </span>
                     </div>
                 </div>

                 <div class="list-group" style="overflow: auto; height: 70%; border: solid 1pt; border-radius: 2px; margin-top: 3px;" id="queriesToDisplay">
                     <ul class="list-group checked-list-box queries" id="querylist">
                     </ul>
                 </div>

                 <div class="btn-group">
                     <button type="button" onclick="selectAll('queries'); false;" class="btn btn-warning"><span class="glyphicon glyphicon-check"></span>Select All</button>
                     <button type="button" onclick="deSelectAll('queries');false;" class="btn btn-warning"><span class="glyphicon glyphicon-unchecked"></span>Unselect All</button>
                 </div>
                 <br />
                 <div class="btn-group">
                     <button type="button" id="delQueriesFromList" onclick="removeQueriesFromList(); false;" class="btn btn-danger"><span class="glyphicon glyphicon-trash"></span>&nbsp;Remove Queries</button>
                 </div>
             </div>

             <div class="col-sm-2 panel" style="height: 95%; top: 33%">
                 <div class="form-group">
                     <span class="input-group-btn">
                         <button class="btn btn-warning" onclick="submitQueries(); false;" runat="server"><span class="glyphicon glyphicon-search"></span>Generate Report</button>
                     </span>
                     <br />
                     <label>
                         <input type="checkbox" class="form-control" id="byRegistration" name="checkbox" value="value" />By Registered Visit</label>
                     <br />
                     <label>
                         <input type="checkbox" class="form-control" id="byScan" name="checkbox" value="value" />By Scanned Location</label>
                 </div>
             </div>

             <div class="col-sm-4 panel" style="height: 95%;">
                 <h3 style="">Query Results</h3>
                 <div class="list-group" style="overflow: auto; height: 85%; border: solid 1pt; border-radius: 2px; margin-top: 3px;" id="queryResult">
                     <ul class="list-group checked-list-box results" id="resultList">
                     </ul>
                 </div>
             </div>
         </div>


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
    <script type="text/javascript" src="<%= Page.ResolveClientUrl("~/Webpage/Staff/UserManagement/loadUsers.js") %>"></script>
    <script type="text/javascript" src="<%= Page.ResolveClientUrl("~/Webpage/Staff/ContactTracing/query.js") %>"></script>
    <script type="text/javascript" src="<%= Page.ResolveClientUrl("~/Webpage/Staff/PassManagement/passManage.js") %>"></script>
    <script type="text/javascript">
        var user = '<%= Session["username"].ToString() %>';
    </script>
</body>
</html>
