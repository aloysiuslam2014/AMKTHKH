<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="TerminalCheckIn.aspx.cs" Inherits="THKH.Webpage.Staff.TerminalCheckIn" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Select Terminal</title>
        <link href="~/Content/bootstrap.min.css" rel="stylesheet" />
    <script type="text/javascript" src="<%= Page.ResolveClientUrl("~/Scripts/jquery-3.1.1.min.js") %>"></script>
    <script type="text/javascript" src="<%= Page.ResolveClientUrl("~/Scripts/bootstrap.min.js") %>"></script>
</head>
<body>
    <form id="form1" runat="server">
    <div>
     <div class="row maxHeight" style="overflow-y: auto">
                            <div id="newusercontent" class="col-sm-6" runat="server">
                                <div class="jumbotron">
                                    <h3>Available Terminals</h3>
                                    <div class="form-group">
                                        <div id="terminalsAvail" class="form-control userDetails" >Waiting for input</div>
                                    </div>
                                    
                                </div>
                            </div>
                            <div id="staticinfocontainer" class="col-sm-6" runat="server">
                                <h3>Select Terminal</h3>
                                <div class="form-group">
                                    <label for="wardno">Ward Number:</label>
                                    <input type="text" runat="server" class="form-control" id="wardno" />
                                </div>
                               
                            </div>

                        </div>
    </div>
    </form>
</body>
</html>
