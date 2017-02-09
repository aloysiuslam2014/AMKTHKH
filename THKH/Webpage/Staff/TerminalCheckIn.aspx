<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="TerminalCheckIn.aspx.cs"   Inherits="THKH.Webpage.Staff.TerminalCheckIn" %>

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
    <form role="form" runat="server" class="center-block" id="checkInForm"  style="width: 80%;">
      <!-- Modal Login-->
  <div class="modal fade" id="myModal" role="dialog">
    <div class="modal-dialog">
    
      <!-- Modal content-->
      <div class="modal-content">
        <div class="modal-header" style="padding:0px 50px;  text-align:center;">
         
          <h4><span class="glyphicon glyphicon-lock"></span> </h4>
           
        </div>
        <div class="modal-body" style="padding:40px 50px; text-align:center;">
         
            <div class="form-group">
              <label for="usrname"><span class="glyphicon glyphicon-user"></span>Verify Staff</label>
              <input type="text"  class="form-control text-center" id="usrname" placeholder="Enter User Login to select a terminal"/>
            </div>
           
              <button type="button" class="btn btn-success btn-block" onclick="verifyUser();"><span class="glyphicon glyphicon-off"></span> Verify</button>
          
        </div>
        <div class="modal-footer" style=" text-align:center !important;">
 <button type="submit" runat="server" class="btn btn-danger btn-default "  onServerClick="returnToLogin"><span class="glyphicon glyphicon-remove"></span> Cancel</button>        </div>
      </div>
      
    </div>
  </div> 
    
      <!-- Modal Alert Fail-->
  <div class="modal fade" id="alertModal" role="dialog">
    <div class="modal-dialog">
    
      <!-- Modal content-->
      <div class="modal-content">
       
        <div class="modal-body" style="padding:40px 50px; text-align:center;">
         
              <label for="usrname" id="errorMsg">Your Verification has failed. Please check your username and try again.</label>
 
        </div>
        <div class="modal-footer" style=" text-align:center !important;">
          <button type="submit" class="btn btn-danger btn-default " data-dismiss="modal"  ><span class="glyphicon glyphicon-remove"></span>Dismiss</button>
           
        </div>
      </div>
      
    </div>
  </div>

  <div id="test" style="width:100%;height:100%;" class="center-block text-center">
        
            <div>
                <ul class="nav navbar-nav " style="display: none;" id="navigatePage">
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
                                   <button type="submit" class="btn btn-danger btn-default " runat="server"  onserverclick="returnToLogin"><span class="glyphicon glyphicon-remove"></span>Return To Login</button>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div id="beginTerminal" class="tab-pane fade">
                        <h3 style="font-size: 7em;"><b>
                            <label id="terminalName"></label>
                        </b></h3>
                        <input type="hidden" id="termValue" />
                         <div class="form-group" id="test22">
                        <input type="password" class="form-control text-center userTextScan" id="userNric"  autofocus />
                        <div id="userWelcome" class="text-success" style="font-size: 4em;">Please Scan Your Card</div>
                             
                        </div>
                    </div>

                </div>

            </div>

            <script type="text/javascript" src="<%= Page.ResolveClientUrl("~/Webpage/Staff/TerminalCalls/locationQueries.js") %>"></script>
       
            <script type="text/javascript">

               

            </script>
        
    </div>

        </form>
</body>
</html>
