<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Login.aspx.cs" Inherits="THKH.Webpage.Staff.Login" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Staff Login | Ang Mo Kio - Thye Hua Kwan Hospital</title>
    <meta name="viewport" content="width=device-width">
    <link href="~/CSS/login.css" rel="stylesheet" />
    <link href="~/Content/bootstrap.min.css" rel="stylesheet" />
    <script type="text/javascript" src="<%= Page.ResolveClientUrl("~/Scripts/jquery-3.1.1.min.js") %>"></script>
    <script type="text/javascript" src="<%= Page.ResolveClientUrl("/Scripts/moment.min.js") %>"></script>
    <script type="text/javascript" src="<%= Page.ResolveClientUrl("~/Scripts/bootstrap.min.js") %>"></script>
   
    

</head>
<body>
    <form id="login" runat="server">
    
    <div class="container">
    <div class="row">
        <div id="loginbox" style="margin-top:35px;" class="mainbox col-md-6 col-md-offset-3 col-sm-8 col-sm-offset-2">
            <div class="panel panel-primary">
                <div class="panel-heading" class="panel-heading">
                    <h3 class="panel-title">
                        Staff Login | Ang Mo Kio - Thye Hua Kwan Hospital</h3>
                </div>
                <div class="panel-body">
                    <div class="row">
                        <div class="col-xs-6 col-sm-6 col-md-6 separator social-login-box"> <br />
                        <img src="../../Assets/AMK_THKH_Logo.png" class="img-responsive" alt="Conxole Admin"/>
                        </div>
                        <div class="col-xs-6 col-sm-6 col-md-6 login-box">
                             
                            <div style="margin-top: 60px" class="input-group">
                                <span class="input-group-addon"><span class="glyphicon glyphicon-user"></span></span>
                                <input id="txtUserName" runat="server" type="text" class="form-control" placeholder="Username" required autofocus />
                            </div>
                            <div style="margin-top: 10px" class="input-group">
                                <span class="input-group-addon"><span class="glyphicon glyphicon-lock"></span></span>
                                <input id="txtUserPass" runat="server" type="password" class="form-control" placeholder="Password" required />
                            </div>
                            
                        </div>
                    </div>
                </div>
                <div class="panel-footer">
                    <div class="row">
                        <div style="margin-left: 275px" class="col-xs-6 col-sm-6 col-md-6">
                            <asp:button runat="server" OnClick="loginSubmit_Click" type="button" class="btn btn-success" Text="Login"/>
                            <asp:button runat="server" OnClick="checkInTerminal_Click" type="button" class="btn btn-primary" Text="Check-In Terminal"/>
                        </div>
                        <label id="errorMsg" runat="server"></label>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>  
    </form>
    
</body>
</html>
