 
var sPositions = {};
var level = 0;

function convertDvToImg() {
    html2canvas($("#passClone"), {
        onrendered: function (canvas) {
            $("#queriesToDisplay").append(canvas);
        }
    });
}

function getPassState() {
    var headersToProcess = {
        requestType: "getPassState"
        
    };
    $.ajax({
        url: '../Staff/PassManagement/passMgmt.ashx',
        method: 'post',
        data: headersToProcess,


        success: function (returner) {
            resultOfGeneration = JSON.parse(returner);
            var res = resultOfGeneration.Result;
            if (res.toString() == "Success") {
                var passSetup = resultOfGeneration.Msg;
                var passLayout = passSetup.divState;
                var elementPositionsJson = JSON.parse(passSetup.positions);
                //var testtt = elementPositionsJson["barcode"];
                createPassAppendParent($("#userSuccess"), passLayout, elementPositionsJson)
            } else {
                alert(resultOfGeneration.Msg);
            }
        },
        error: function (err) {
            alert(err.Msg);
        },

    });


}

function savePassState() {
    var cloneDump = $("#passLayout").clone()[0];
    $(cloneDump).prop("id", "passClone");
   
  
    var storePassState = $(cloneDump).prop('outerHTML').replace(/"/g, "'");
    var headersToProcess = {
        requestType: "savePassState",
        passState: storePassState,
        positioning: JSON.stringify(sPositions)
    };
    $.ajax({
        url: '../Staff/PassManagement/passMgmt.ashx',
        method: 'post',
        data: headersToProcess,


        success: function (returner) {
            resultOfGeneration = JSON.parse(returner);
            var res = resultOfGeneration.Result;
            if (res.toString() == "Success") {
                alert("State Saved");
            } else {
                alert(resultOfGeneration.Msg);
            }
        },
        error: function (err) {
            alert(err.Msg);
        },
    });
}


function createPassAppendParent(parent, target, datapositions) {
    $(parent).append(target);
    target = $("#passClone");
    $(target).children().each(function () {//remove event listeners and dashborder
        $(this).off('contextmenu');
        $(this).attr('oncontextmenu', '');
        $(this).prop('oncontextmenu', '');
        $(this).removeClass("dashedBorderAbsolute"); 
        $(this).addClass("forceAbsolute");
        $(this).css('color', 'black');
        $("#" + this.id + " .ui-resizable-handle").remove();//remove special symbols to adjust the image or barcode of text size
       // $("#" + this.id + " .ui-resizable").remove();//remove special symbols to adjust the image or barcode of text size
    });
    
   
    $(target).children().each(function () {
       //set the elements position to its correct place based on offset
        var name = this.id;
        var leftposition = datapositions[name].left;
        var targetLeft = $(target).position().left;
        var targetTop = $(target).position().top;
        $(this).css({ top: datapositions[name].top + targetTop, left: datapositions[name].left + targetLeft });
       
    });

    //Generate new barcode and replace existing barcode value
    var barcodeElement = $("#"+$(target)[0].id).find("#barcode img");
    if(barcodeElement == null){
        $(barcodeElement).remove();
    }else{
        var getNric = $("#registration").find("#nric").val();
       createBarCodeImg(getNric, barcodeElement[0]);
       
          
    }
    //Set the values from the field if id matches label's id

    $(target).children().each(function () {
        //set the elements position to its correct place based on offset
        var name = this.id;
        var inputVal = $("#userData").find("#" + name);
        if (inputVal != null) {
            $(this).html($(inputVal).val());
        }
       
    });

    clearFields();
 
}

function createDraggablElement(element) {
    $(element).draggable({
        stack: "#passLayout .zax", snap: "#passLayout", snapTolerance: 1, containment: "#passLayout", scroll: false,
        stop: function (event, ui) {
            var $this = $(this);
            var thisPos = $this.position();
            var parentPos = $this.parent().position();
           
            var x = thisPos.left - parentPos.left;
            var y = thisPos.top - parentPos.top;
            var storedPoints = { top:y, left: x};
            sPositions[this.id] = storedPoints;
        }
    });
    $(element).attr("oncontextmenu", "deletAddedElement(event);");
    $(element).css("z-index", level++);
    $(element).css("text-overflow", "ellipsis");
    $(element).addClass("dashedBorderAbsolute");
    $(element).addClass("zax");
}

function changePassDimen(width,height){
    $("#passLayout").css("width", width);
    $("#passLayout").css("height", height);
}

function customDimenstions() {
    var dimensionss = customSizePass.value.split("*");
    changePassDimen(dimensionss[0], dimensionss[1]);
}

function toggleOrientation() {
    var width = $("#passLayout").width();
    var height = $("#passLayout").height();
    $("#passLayout").width(height);
    $("#passLayout").height(width);
}

function addTextToPass() {
    //text-overflow:ellipsis
    var selectedSource = $("#source").val();
    
    if (selectedSource == "custom") {
        selectedSource = $("#customText").val();
        
    }
   
    var labelToInsert = document.createElement("label");
    
    $(labelToInsert).html( selectedSource);
    $(labelToInsert).prop("value", selectedSource);
    $(labelToInsert).prop("class", selectedSource);
    $(labelToInsert).prop("id", selectedSource);
    $(labelToInsert).prop("style", "text-overflow:ellipsis; ");
    $(labelToInsert).resizable({
        containment: "#passLayout"
    });
    createDraggablElement(labelToInsert);
    
    $("#passLayout ").append(labelToInsert);
 
}

function ifCustom() {
    var selectedSource = $("#source").val();
    if (selectedSource == "custom") {
        $("#customText").toggle(true);
    } else {
        $("#customText").toggle(false);
    }
}

function deletAddedElement(eventSelect){
    if (eventSelect.which == 3) {
        eventSelect.preventDefault();
        $(eventSelect.currentTarget).remove();         
    }
}

function addBarCodeToPassLayout() {
    var barcode = createBarCodeImg("s98375843");
    var divWrapper = document.createElement("div");
    $(divWrapper).attr("style", "display:inline-block");
    $(divWrapper).css("z-index", level++);
    $(divWrapper).append(barcode);
    $(barcode).width("100px");
    $(barcode).height("100px")
    $(barcode).resizable({
        containment: "#passLayout"
    });
    $(divWrapper).attr("id", "barcode");

    createDraggablElement(divWrapper);
 
    $("#passLayout ").append(divWrapper);
}


function createBarCodeImg(textToCreate,injectAfterLoad) {
    var imageToCreate = new Image();
   
    var headersToProcess = {
        requestType: "generateBar", textEnc: textToCreate
    };
    $.ajax({
        url: '../Staff/PassManagement/passMgmt.ashx',
        method: 'post',
        data: headersToProcess,


        success: function (returner) {
            resultOfGeneration = JSON.parse(returner);
            if (resultOfGeneration.Result == "Success") {
                if (injectAfterLoad == null) {
                    imageToCreate.src = 'data:image/png;base64,' + resultOfGeneration.Msg;
                } else {
                    injectAfterLoad.setAttribute('src', 'data:image/png;base64,' + resultOfGeneration.Msg);
                }
               

            } else {
                alert(resultOfGeneration.Msg);
            }
        },
        error: function (err) {
            alert(err.Msg);
        },
    });
    return imageToCreate;
}
var imgcounter = 0;
function createImageAndAdd(me) {
    var imageToCreate = new Image();
    
    var FR = new FileReader();
    FR.onload = function (e) {
        imageToCreate.src = e.target.result;
       
    };
    FR.readAsDataURL(me.files[0]);
    var divWrapper = document.createElement("div");
    $(divWrapper).attr("style", "display:inline-block");
    $(divWrapper).attr("id", "img" + imgcounter);
    $(divWrapper).css("z-index", level++);
    $(divWrapper).append(imageToCreate);
    $(imageToCreate).width("100px");
    $(imageToCreate).height("100px")
    $(imageToCreate).resizable({
        containment: "#passLayout"
    });
    createDraggablElement(divWrapper);

    $("#passLayout ").append(divWrapper);
}

