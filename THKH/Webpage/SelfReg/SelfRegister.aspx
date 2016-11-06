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
    <style type="text/css">
    .buttonedge {
        border-top-left-radius: 4px; border-bottom-left-radius: 4px
    }
    .contentNav {
  display: inline-block;
  float: none;
  vertical-align: top;
   text-align: center;
   margin-bottom:0;
}
    </style>
</head>
<body>
    <form id="selfregistration" runat="server">
        <div id="maincontainer" class="container-fluid" runat="server">
            <nav class="navbar navbar-default navbar-fixed-top">
                <div class="container-fluid contentNav">
                    <div class="navbar-header ">
                        <a class="navbar-brand"><b>Thye Hua Kwan Hospital</b></a>
                    </div>
                </div>
            </nav>
            <br />
            <br />
            <br />
            <a data-controls-modal="myModal" data-backdrop="static" data-keyboard="false" href="#">
                <button type="button" class="btn btn-success btn-block" data-toggle="modal" data-target="#myModal">Choose User</button>
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
                                    <asp:LinkButton ID="NewVisitorButton" CssClass="btn btn-primary buttonedge" runat="server" OnClick="LinkButton1_Click" OnClientClick="isNew.value=1;">New Visitor</asp:LinkButton>
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
                <div class="container-fluid">
                    <div class="row">
                        <div id="newusercontent" class="col-sm-6" runat="server">
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
                            <div class="form-group">
                                <label for="postalinput">Postal Code:</label>
                                <asp:TextBox runat="server" CssClass="form-control" ID="postalinput"></asp:TextBox>
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
                                <asp:TextBox runat="server" CssClass="form-control" ID="nationalinput"></asp:TextBox>
                            </div>
                            <div class="form-group">
                                <label for="daterange">Date of Birth:</label>
                                <asp:TextBox runat="server" CssClass="form-control" ID="daterange">01/01/2015 - 01/31/2015</asp:TextBox>
                            </div>
                        </div>
                            </div>
                        <div id="existingusercontent" class="col-sm-6" runat="server">
                            <h3>Please Enter your NRIC</h3>
                            <div class="form-group">
                                <label for="existnric">NRIC:</label>
                                <asp:TextBox runat="server" CssClass="form-control" ID="existnric"></asp:TextBox>
                            </div>
                        </div>
                        <div id="staticinfocontainer" class="col-sm-6" runat="server">
                            <h3>Visit Health Questionnaire</h3>
                            <div class="form-group">
                                <label for="wardno">Ward Number:</label>
                                <asp:TextBox runat="server" CssClass="form-control" ID="wardno"></asp:TextBox>
                            </div>
                            <div class="form-group">
                                <label for="wingno">Wing Number:</label>
                                <asp:TextBox runat="server" CssClass="form-control" ID="wingno"></asp:TextBox>
                            </div>
                            <div class="form-group">
                                <label for="cubno">Cubicle Number:</label>
                                <asp:TextBox runat="server" CssClass="form-control" ID="cubno"></asp:TextBox>
                            </div>
                            <div class="form-group">
                                <label for="bedno">Bed Number:</label>
                                <asp:TextBox runat="server" CssClass="form-control" ID="bedno"></asp:TextBox>
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
                                <asp:TextBox runat="server" CssClass="form-control" TextMode="MultiLine" Rows="5" ID="healthcheck"></asp:TextBox>
                            </div>

                        </div>
                    </div>
                    <div id="submitExist"  runat="server" class="container-fluid">
                        <asp:LinkButton ID="submitNricButton" CssClass="btn btn-success btn-block" runat="server" OnClick="SubmitExistNRIC">Submit</asp:LinkButton>
                    </div>
                    <div id="submitNew" runat="server" class="container-fluid">
                        <asp:LinkButton ID="submitNewEntryButton" CssClass="btn btn-success btn-block" runat="server" OnClick="SubmitNewReg">Submit New Registration</asp:LinkButton>
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

    <input type="hidden" id="isNew" value="0" runat="server">
</body>
</html>
