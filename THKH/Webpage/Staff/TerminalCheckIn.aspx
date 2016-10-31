<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="TerminalCheckIn.aspx.cs" Inherits="THKH.Webpage.Staff.TerminalCheckIn" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Select Terminal</title>
    <link href="~/Content/bootstrap.min.css" rel="stylesheet" />
    <script type="text/javascript" src="<%= Page.ResolveClientUrl("~/Scripts/jquery-3.1.1.min.js") %>"></script>
    <script type="text/javascript" src="<%= Page.ResolveClientUrl("~/Scripts/bootstrap.min.js") %>"></script>
    <link href="~/CSS/default.css" rel="stylesheet" />
        <link href="~/CSS/terminal.css" rel="stylesheet" />

</head>
<body>
    <form id="form1" style="width: 80%;" runat="server">
        <div>
            <ul class="nav navbar-nav " style="display:none;" id="navigatePage">
                    <li>
                        <a href="#setTerminal" data-toggle="tab">1
                        </a>
                    </li>
                    <li>
                        <a href="#beginTerminal" data-toggle="tab">2
                        </a>
                    </li>
                   
                </ul> 
            <div class="tab-content">
                <div id="setTerminal" class="tab-pane fade in active">
                    <div class="row maxHeight" style="overflow-y: auto">
                        <div id="newusercontent" class="col-sm-12" runat="server">
                            <div class="jumbotron">
                                <h3>Available Terminals</h3>
                                <div class="form-group">
                                    <div id="terminalsAvail" runat="server" class="form-control userDetails"></div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
                <div id="beginTerminal" class="tab-pane fade">
                    <h3 style="font-size: 7em;"><b>Terminal <label id="terminalName"></label></b></h3>
                    <input type="hidden" id="termValue"/>
                    <input type="text" class="form-control userTextScan" id="userNric" onchange="updateCheckIn()"/>
                    <label id="userWelcome" class="text-success" style="font-size: 4em;">Please Scan Your Card</label>
                </div>
                
            </div>

        </div>
        <script type="text/javascript">

            function activateMe(me) {
                activaTab("beginTerminal");
                var nameAndId = me.id.toString().split(":");
                terminalName.textContent = nameAndId[0];
                termValue.value = nameAndId[1];
                var headersToProcess = { action: "activate", id: nameAndId[1] };
                $.ajax({
                    url: './TerminalCalls/TerminalCheck.ashx',
                    method: 'post',
                    data: headersToProcess,
                    success: function (returner) {

                    },
                    error: function (err) {
                    },
                });
            }

            function activaTab(tab) {
                $(' a[href="#' + tab + '"]').tab('show');
               
            }

            function updateCheckIn() {
                var headersToProcess = { action: "checkIn", id: termValue.value, user: userNric.value };
                $.ajax({
                    url: './TerminalCalls/TerminalCheck.ashx',
                    method: 'post',
                    data: headersToProcess,
                    success: function (returner) {

                    },
                    error: function (err) {
                    },
                });
            }


        </script>
    </form>
</body>
</html>
