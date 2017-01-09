function createDraggablElement(element) {
    $(element).draggable({ stack: "#passLayout .zax", snap: "#passLayout", snapTolerance: 1, containment: "#passLayout", scroll: false });
    $(element).attr("oncontextmenu", "deletAddedElement(event);");
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
    $(labelToInsert).html(selectedSource); 
    $(labelToInsert).prop(selectedSource); 
    $(labelToInsert).prop("style", "text-overflow:ellipsis; ");
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
    createDraggablElement(barcode);
 
    $("#passLayout ").append(barcode);
}


function createBarCodeImg(textToCreate) {
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
                imageToCreate.src = 'data:image/png;base64,' + resultOfGeneration.Msg;
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

function createImageAndAdd(me) {
    var imageToCreate = new Image();
    
    var FR = new FileReader();
    FR.onload = function (e) {
        imageToCreate.src = e.target.result;
       
    };
    FR.readAsDataURL(me.files[0]);
    createDraggablElement(imageToCreate);

    $("#passLayout ").append(imageToCreate);
}