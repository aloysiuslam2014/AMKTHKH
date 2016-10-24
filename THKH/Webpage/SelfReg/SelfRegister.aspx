<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="SelfRegister.aspx.cs" Inherits="THKH.Webpage.SelfReg.SelfRegister" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>AMKTHKH Visitor Self-Registration</title>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <link href="~/Content/bootstrap.min.css" rel="stylesheet" />
    <script type="text/javascript" src="<%= Page.ResolveClientUrl("~/Scripts/jquery-3.1.1.min.js") %>"></script>
    <script type="text/javascript" src="<%= Page.ResolveClientUrl("~/Scripts/bootstrap.min.js") %>"></script>
</head>
<body>
    <form id="selfregistration" runat="server">
        <div id="maincontainer" class="container-fluid" runat="server">
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
                        </ul>
                    </div>
                </div>
            </nav>
            <br />
            <br />
            <br />
            <a data-controls-modal="myModal" data-backdrop="static" data-keyboard="false" href="#">
                <button type="button" class="btn btn-success" data-toggle="modal" data-target="#myModal">Choose User</button>
                <div class="modal fade" id="myModal" tabindex="-1" role="dialog" aria-labelledby="memberModalLabel" aria-hidden="true">
                    <div class="modal-dialog">
                        <div class="modal-content">
                            <div class="modal-header">
                                <%--<button type="button" class="close" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">&times;</span></button>--%>
                                <img src="../../Assets/hospitalLogo.png" class="img img-responsive" />
                                <h4 class="modal-title" id="memberModalLabel">Select an Option to Begin Self-Registration</h4>
                            </div>
                            <div class="modal-body">
                                <div class="btn-group">
                                    <%-- <button type="button" class="btn btn-primary" onclick="showNewContent()">New Visitor</button>--%>
                                    <asp:LinkButton ID="NewVisitorButton" CssClass="btn btn-primary" runat="server" OnClick="LinkButton1_Click">New Visitor</asp:LinkButton>
                                    <%--                            <button type="button" class="btn btn-primary" onclick="showExistContent()">Existing Visitor</button>--%>
                                    <asp:LinkButton ID="ExistingVisitorButton" runat="server" CssClass="btn btn-primary" OnClick="LinkButton2_Click">Existing Visitor</asp:LinkButton>
                                </div>
                            </div>
                            <div class="modal-footer">
                                <%--<button type="button" class="btn btn-danger" data-dismiss="modal">Close</button>--%>
                            </div>
                        </div>
                    </div>
                </div>
                <div id="staticinfocontainer" class="container-fluid" runat="server">
                    <div class="jumbotron">
                        <h3>Static Questions</h3>
                        <div id="newusercontent" class="container-fluid" runat="server">
                            <div class="jumbotron">
                                <h3>Personal Details</h3>
                                <div class="form-group">
                                    <asp:Label ID="lblname" Text="Name:" runat="server"></asp:Label>
                                    <asp:TextBox runat="server" CssClass="form-control" ID="nameinput"></asp:TextBox>
                                </div>
                                <div class="form-group">
                                    <label for="emailinput">Email address:</label>
                                    <asp:TextBox runat="server" CssClass="form-control" ID="emailinput"></asp:TextBox>
                                </div>
                                <div class="form-group">
                                    <label for="nricinput">NRIC:</label>
                                    <asp:TextBox runat="server" CssClass="form-control" ID="nricinput"></asp:TextBox>
                                </div>
                                <div class="form-group">
                                    <label for="mobileinput">Mobile Number:</label>
                                    <asp:TextBox runat="server" CssClass="form-control" ID="mobileinput"></asp:TextBox>
                                </div>
                                <div class="form-group">
                                    <label for="homeinput">Home Number:</label>
                                    <asp:TextBox runat="server" CssClass="form-control" ID="homeinput"></asp:TextBox>
                                </div>
                                <div class="form-group">
                                    <label for="addressinput">Address:</label>
                                    <asp:TextBox runat="server" CssClass="form-control" ID="addressinput"></asp:TextBox>
                                </div>
                            </div>
                        </div>
                        <div id="existingusercontent" class="container-fluid" runat="server">
                            <div class="jumbotron">
                                <h3>Please Enter your NRIC</h3>
                                <div class="form-group">
                                    <label for="existnric">NRIC:</label>
                                    <asp:TextBox runat="server" CssClass="form-control" ID="existnric"></asp:TextBox>
                                    <asp:LinkButton ID="submitExistNricButton" CssClass="btn btn-success" runat="server" OnClick="SubmitExistNRIC">Submit</asp:LinkButton>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
        </div>
    </form>
    <script type="text/javascript">
        $(window).load(function () {
            if (sessionStorage["PopupShown"] != 'yes') {
                $('#myModal').modal('show');
                sessionStorage["PopupShown"] = 'yes';
            }
        });

        function showModal() {
            $('#myModal').modal('show');
        }

        function hideModal() {
            $('#myModal').modal('hide');
        }

        function showNewContent() {
            $('#newusercontent').visible = true;
        }

        function showExistContent() {
            showNewContent();
            $('#existingusercontent').visible = true;
        }

        function showStaticContent() {
            showNewContent();
            $('#staticinfocontainer').visible = true;
        }

    </script>
</body>
</html>
