<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Default.aspx.cs" Inherits="THKH.Webpage.Staff.Default" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <meta charset="utf-8">
    <title>Welcome "username"</title>
    <link href="~/Content/bootstrap.min.css" rel="stylesheet" />
    <script type="text/javascript" src="<%= Page.ResolveClientUrl("~/Scripts/jquery-3.1.1.min.js") %>"></script>
    <script type="text/javascript" src="<%= Page.ResolveClientUrl("~/Scripts/bootstrap.min.js") %>"></script>
    
    <link href="~/CSS/default.css" rel="stylesheet" />





</head>
<body>

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
                                <asp:Button id="logout" class="btn" Text="logout" OnClick="logout_Click" runat="server" />
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
                                <div class=" row padRows" id="tempField" >
                                    <div class="col-lg-4 col-lg-offset-4">
                                        Temperature:<input runat="server" id="temp" class="form-control" type="text" /><input class="btn btn-default" type="submit" id="checkInBtn" runat="server" value="Check-In" />
                                    </div>
                                </div>
                                <div class="row padRows">
                                    <div class="col-lg-10 col-lg-offset-1">
                                        <div id="Details" class="form-control userDetails" >Waiting for input</div>
                                        
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>

                    <div class="tab-pane maxHeight" id="regVisit">
                        <div class="row maxHeight" style="overflow-y:auto">
                          <div id="newusercontent" class="col-sm-6" runat="server">
                            <div class="jumbotron">
                            <h3>Personal Details</h3>
                            <div class="form-group">
                                <asp:Label id="lblname" Text="Name:" runat="server"></asp:Label>
                                <input type="text" runat="server" class="form-control" id="namesInput" />
                            </div>
                            <div class="form-group">
                                <label for="emailinput">Email address:</label>
                                <input type="text" runat="server" class="form-control" id="emailsInput"/>
                            </div>
                            <div class="form-group">
                                <label for="nricinput">NRIC:</label>
                                <input type="text" runat="server" class="form-control" id="nricsInput"/>
                            </div>
                            <div class="form-group">
                                <label for="mobileinput">Mobile Number:</label>
                                <input type="text" runat="server" class="form-control" id="mobilesInput"/>
                            </div>
                            <div class="form-group">
                                <label for="homeinput">Home Number:</label>
                                <input type="text" runat="server" class="form-control" id="homesInput"/>
                            </div>
                            <div class="form-group">
                                <label for="addressinput">Address:</label>
                                <input type="text" runat="server" class="form-control" id="addresssInput"/>
                            </div>
                            <div class="form-group">
                                <label for="postalinput">Postal Code:</label>
                                <input type="text" runat="server" class="form-control" id="postalsInput"/>
                            </div>
                            <div class="form-group">
                                <label for="sexinput">Gender:</label>
                                <select class="form-control" id="sexinput">
                                    <option>Male</option>
                                    <option>Female</option>
                                </select>
                            </div>
                            <div class="form-group">
                                <label for="nationalinput">Nationality:</label>
                                <input type="text" runat="server" class="form-control" id="nationalsInput"/>
                            </div>
                            <div class="form-group">
                                <label for="daterange">Date of Birth:</label>
                                <input type="text" runat="server" class="form-control" id="datesRange" value="01/01/2015 - 01/31/2015"/>
                            </div>
                        </div>
                            </div>
                        <div id="staticinfocontainer" class="col-sm-6" runat="server">
                            <h3>Visit Health Questionnaire</h3>
                            <div class="form-group">
                                <label for="wardno">Ward Number:</label>
                                 <input type="text" runat="server" class="form-control" id="wardno"/>
                            </div>
                            <div class="form-group">
                                <label for="wingno">Wing Number:</label>
                                 <input type="text" runat="server" class="form-control" id="wingno"/>
                            </div>
                            <div class="form-group">
                                <label for="cubno">Cubicle Number:</label>
                                 <input type="text" runat="server" class="form-control" id="cubno"/>
                            </div>
                            <div class="form-group">
                                <label for="bedno">Bed Number:</label>
                                 <input type="text" runat="server" class="form-control" id="bedno"/>
                            </div>
                            <div class="form-group">
                                <label for="visitbookingtime">Appointment Time:</label>
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
                            <div class="form-group">
                                <label for="healthcheck">Past Medical Issues (In the last 6 months):</label>
                                 <textarea runat="server" class="form-control" TextMode="MultiLine" Rows="5" id="healthcheck"/>
                            </div>
                        </div>

                        </div>
                    </div>
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
                    isadosdoasjdakdadsdasjadslsdk</p>
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

    <script type="text/javascript">

        $('#navigatePage a:first').tab('show');
        $('#regPageNavigation a:first').tab('show');
        nric.value.toString();
    </script>
    <script type="text/javascript" src="<%= Page.ResolveClientUrl("~/Scripts/registrationPageScripts.js") %>"></script>
</body>
</html>
