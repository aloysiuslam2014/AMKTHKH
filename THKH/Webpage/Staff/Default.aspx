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
                                <li >
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
                                           <label>Welcome, user</label>   <asp:Button ID="logout" CssClass="btn" Text="logout" OnClick="logout_Click" runat="server" />
                                        </div>
                                    </form>
                        
                        </a></li>
                              </ul>
                    </div>
                        </div>
                </nav>
          
       
                <div class="container">

                    <div class="tab-content maxHeight" id="generalContent">

                        <div class="tab-pane maxHeight" id="registration">
                           <div class="jumbotron maxHeight">
                               <nav class="navbar navbar-default">
                                  <div class="container-fluid ">
                                    
                                    <ul class="nav navbar-nav contentNav" style="margin-bottom:0;" id="regPageNavigation">
                                      
                                      <li><a href="#checkIn"  rel="checkIn""#checkIn">Check-In Visitor</a></li>
                                      <li><a href="#regVisit" data-target="#regVisit">Register Visitor</a></li> 
                                      
                                    </ul>
                                  </div>
                                </nav>
                               <div class="tab-content maxHeight" id="regContent">
                                   <div class="tab-pane maxHeight" id="checkIn">
                                       <div class="jumbotron maxHeight">Test</div>
                                   </div>
                                   <div class="tab-pane maxHeight" id="regVisit">
                                         <div class="jumbotron maxHeight">Test2</div>
                                   </div>
                               </div>
                           </div>
                            <br />

                        </div>

                        <div class="tab-pane" id="formManagement">
                            <p><br /><br /><br /><br /><br /><br /><br /><br /><br /><br /><br /><br />isadosdoasjdakdadsdasjadslsdk</p>
                        </div>

                        <div class="tab-pane" id="userManagement">
                            <br /><br /><br /><br /><br /><br /><br /><br /><br /><br /><br /><br /><p>oiafosdoiadsoadsij</p>
                        </div>
                    </div>

                </div>

     <script type="text/javascript">

         $('#navigatePage a:first').tab('show');
         $('#regPageNavigation a:first').tab('show');
    </script>   
</body>
</html>
