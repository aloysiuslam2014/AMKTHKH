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
    
     <div class="container-fluid">
         <img src="../../Assets/hospitalLogo.png" style="width:50%;height:50%"/><br /><br />
         <h2>Triage 2.0 | Staff Login</h2>
        <table class="center">
            
            <tr><td class=""><b>Username: </b></td><td><input id="txtUserName" class="form-control" type="text" runat="server" placeholder="Username" autofocus/></td></tr>
            <tr><td class=""><b>Password: </b></td><td><input id="txtUserPass" class="form-control" type="password" placeholder="Password" runat="server" /></td></tr>
            <tr><br /><br /></tr>
            <tr><td colspan="2" align="center">
                <br />
                <div class="btn-group">
                <asp:Button type="submit" Text="Login" runat="server" id="loginSubmit" OnClick="loginSubmit_Click" class="btn btn-success" />
                <asp:Button type="submit" Text="Check-In Terminal" runat="server" id="checkInTerminal" OnClick="checkInTerminal_Click" class="btn btn-primary" />
                </div>
                    </td></tr>
            <tr><td colspan="2" align="center"><label id="errorMsg" runat="server" ></label></td></tr>
        </table>
    </div>
    </form>
    
</body>
</html>
