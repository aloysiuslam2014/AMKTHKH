<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Default.aspx.cs" Inherits="THKH.Webpage.Staff.Default" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <meta charset="utf-8">
    <title>Welcome "username"</title>
    <link href="~/Content/bootstrap.min.css" rel="stylesheet" />
    <script type="text/javascript" src="<%= Page.ResolveClientUrl("~/Scripts/jquery-3.1.1.min.js") %>"></script>
    <script type="text/javascript" src="<%= Page.ResolveClientUrl("~/Scripts/bootstrap.min.js") %>"></script>



    <script type="text/javascript">

        $('#navigatePage a:first').tab('show');
    </script>
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
                                <li><a href="#">
                                    <form id="form1" runat="server">
                                        <div>
                                            <asp:Button ID="logout" CssClass="btn" Text="logout" OnClick="logout_Click" runat="server" />
                                        </div>
                                    </form>
                        
                        </a></li>
                              </ul>
                    </div>
                        </div>
                </nav>
          
       
                <div class="container">

                    <div class="tab-content">

                        <div class="tab-pane" id="registration">
                            <p>isadosdoasjd</p>
                        </div>

                        <div class="tab-pane" id="formManagement">
                            <p>isadosdoasjdakdadsdasjadslsdk</p>
                        </div>

                        <div class="tab-pane" id="userManagement">
                            <p>oiafosdoiadsoadsij</p>
                        </div>
                    </div>

                </div>
            
    </table>
</body>
</html>
