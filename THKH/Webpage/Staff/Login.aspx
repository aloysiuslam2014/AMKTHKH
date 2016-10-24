<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Login.aspx.cs" Inherits="THKH.Webpage.Staff.Login" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Thye Hua Kwan Hospital - Staff Login -</title>
    <meta name="viewport" content="width=device-width">
    <link href="~/CSS/login.css" rel="stylesheet" />
    <link href="~/Content/bootstrap.min.css" rel="stylesheet" />
   
    

</head>
<body>
    <form id="login" runat="server">
    
     <section>
         <img src="../../Assets/hospitalLogo.png" style="width:50%;height:50%"/>
        <table class="center">
            
            <tr><td class=""><b>Username:</b></td><td><input id="txtUserName" class="txbox" type="text" runat="server" /></td></tr>
            <tr><td class=""><b>Password:</b></td><td><input id="txtUserPass" class="txbox" type="password" runat="server" /></td></tr>
            <tr><td colspan="2" align="center">
                <asp:Button type="submit" Text="Login" runat="server" id="loginSubmit" OnClick="loginSubmit_Click" class="btn" />
                <asp:Button type="submit" Text="Check-In Terminal" runat="server" id="Button1" OnClick="loginSubmit_Click" class="btn" />
                </td></tr>
            <tr><td colspan="2" align="center"><label id="errorMsg" runat="server" ></label></td></tr>
        </table>
    </section>
    </form>
    
</body>
</html>
