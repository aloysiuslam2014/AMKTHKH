var toPassMgmt = '../Staff/PassManagement/passMgmt.ashx';
var printerName = "POS";
var passGenerationFailed = "An error has occured while retrieveing the pass. ";
var ajaxPassconnectionFailure = "Ajax connection failed. Server filed not found or server offline. Please contact the administrator.";

var sPositions = {};
var level = 0;
var loadPassOnce = false;
var creatingPass = false;
function convertDvToImg() {
    html2canvas($("#passClone"), {
        onrendered: function (canvas) {
            $(canvas).prop('id', 'imgPass');
            $("#userSuccess").append(canvas);
            $("#passClone").remove();
        }
    });
}

function convertMMtoPx(mmvalue) {
    //http://www.translatorscafe.com/unit-converter/typography/4-8/ convert to px from mm formula from here
    var convertedpx = (parseInt(mmvalue.replace('mm', '')) * 3.78) + "px";
    return convertedpx;
}

function loadPassState() {


    if ($('#passContainers').is(':visible')) { //if the container is visible on the page
        if (loadPassOnce) {
            return; // only load pass once
        }
        loadPassOnce = true;
        var headersToProcess = {
            requestType: "getPassState"
        };
        $.ajax({
            url: toPassMgmt,
            method: 'post',
            data: headersToProcess,
            success: function (returner) {
                resultOfGeneration = JSON.parse(returner);
                var res = resultOfGeneration.Result;
                if (res.toString() == "Success") {
                    var passSetup = resultOfGeneration.Msg;
                    if (passSetup != null) { //pass configurations exist
                        var passLayout = passSetup.divState;
                        var passProcess = $(passLayout);
                        cleanChildrenElements(passProcess);
                        $("#passContainers").append(passProcess);
                        $("#passContainers #passClone").attr("id", "passLayout");
                        $("#passContainers #passLayout").children().each(function () {
                            if ($(this).attr("id").includes("img") || $(this).attr("id") == "barcode") {
                                $(this).find("img").appendTo($(this));
                                $(this).find(".ui-wrapper").remove();

                                $(this).find("img").resizable({
                                    containment: "#passLayout"
                                });
                                createDraggablElement(this);
                            } else {
                                if (!$(this).hasClass('notResizable')) {
                                    $(this).resizable({
                                        containment: "#passLayout"
                                    });
                                }
                                createDraggablElement(this);
                            }
                        });
                    } else {
                        var passNew = document.createElement("div");
                        $(passNew).attr("style", "background-color: white; border: 1px solid; height: 197px; width: 280px; margin: auto;margin-top:40px;position:relative");
                        $(passNew).attr("id", "passLayout");
                        $("#passContainers").append(passNew);
                        return;
                    }
                } else {
                    alert(resultOfGeneration.Msg);
                }
            },
            error: function (err) {
                alert(ajaxPassconnectionFailure);
            },

        });
    } else {
        setTimeout(loadPassState, 100); //wait 100 ms if div hasnt finished rendering yet, then try again
    }

}

function getPassState() {
    var headersToProcess = {
        requestType: "getPassState"

    };
    $.ajax({
        url: toPassMgmt,
        method: 'post',
        data: headersToProcess,


        success: function (returner) {
            resultOfGeneration = JSON.parse(returner);
            var res = resultOfGeneration.Result;
            if (res.toString() == "Success") {

                var passSetup = resultOfGeneration.Msg;
                if (passSetup != null) {
                    var passLayout = passSetup.divState;
                    var elementPositionsJson = JSON.parse(passSetup.positions);
                    createPassAppendParent($("#userSuccess"), passLayout, elementPositionsJson)
                } else {

                }

            } else {
                //alert(resultOfGeneration.Msg);
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


    var storePassState = $(cloneDump).prop('outerHTML');
    var headersToProcess = {
        requestType: "savePassState",
        passState: storePassState,
        positioning: JSON.stringify(sPositions)
    };
    $.ajax({
        url: toPassMgmt,
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
    $("#passClone").remove();
    $(parent).append(target);
    target = $("#passClone");
    $(target).children().each(function () {//remove event listeners and dashborder
        $(this).off('contextmenu');
        $(this).attr('oncontextmenu', '');
        $(this).prop('oncontextmenu', '');
        cleanChildrenElements(this);
        $(this).addClass("forceAbsolute");
        $(this).css('color', 'black');
    });
    //Generate new barcode and replace existing barcode value
    var barcodeElement = $("#" + $(target)[0].id).find("#barcode img");
    if (barcodeElement == null) {
        $(barcodeElement).remove();
    } else {
        var getNric = $("#registration").find("#nric").prop('value');
        creatingPass = true;//flag as creating a pass so the div will be converted to an img afterwards
        createBarCodeImg(getNric, barcodeElement[0]);
    }
    //Set the values from the field if id matches label's id

    $(target).children().each(function () {
        //set the elements value based on id
        var name = this.id;
        var currentItem = this;
        if (name == "bedno") {
            var inputVal = $("#userData").find("#bedsAdded");
            if (inputVal != null) {
                var bedTodisplay = "";
                var numbOfBeds = $(inputVal).children().length;
                $(inputVal).children().each(function (index, item) {
                    bedTodisplay += item.id;
                    if (index + 1 < numbOfBeds) {
                        bedTodisplay += ",";
                    }
                });
                $(currentItem).html(bedTodisplay);
            }
        } else {
            var inputVal = $("#userData").find("#" + name);
            if (name == "vnric") {
                inputVal = $("#nurseInputArea #nric");
            }
            var originWidth = $(currentItem).width();
            if (inputVal != null) {
                $(currentItem).html($(inputVal).val());
            }
            if ($(currentItem).css("text-align") == "center") {
                var updatedLeft = $(currentItem).prop("offsetLeft") - (($(currentItem).width() - originWidth) / 2);
                $(currentItem).css("left", updatedLeft + "px")
            }
        }
    });
}

function cleanChildrenElements(element) {

    if (element.id != "") {
        $(element).find(".ui-resizable-handle").remove();//remove special symbols to adjust the image or barcode of text size
    }
    $(element).removeClass("dashedBorderAbsolute");
    $(element).removeClass('ui-resizable');
    $(element).removeClass('ui-draggable');
    $(element).removeClass('ui-draggable-handle');
    $(element).removeClass('zax');
    var childEle = $(element).children();
    if (childEle.length > 0) {
        $(childEle).each(function () { cleanChildrenElements(this) });
    }

}

function createDraggablElement(element) {
    $(element).draggable({
        stack: "#passLayout .zax", snap: "#passLayout", snapTolerance: 1, containment: "#passLayout", scroll: false,
        create: function (event, ui) {
        },
        stop: function (event, ui) {
            var $this = $(this)[0];
            var x = $this.offsetLeft;
            var y = $this.offsetTop;
            var storedPoints = { top: y, left: x };
            sPositions[this.id] = storedPoints;
        }
    });
    $(element).attr("oncontextmenu", "deletAddedElement(event);");
    $(element).css("z-index", level++);
    $(element).css("text-overflow", "ellipsis");
    $(element).addClass("dashedBorderAbsolute");
    $(element).addClass("zax");
}

function changePassDimen(width, height) {
    $("#passLayout").css("width", convertMMtoPx(width));
    $("#passLayout").css("height", convertMMtoPx(height));
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
    if ($('input[name="textPosition"]:checked').val() != null) {
        $(labelToInsert).css('text-align', ($('input[name="textPosition"]:checked').val()));
    }
    if ($('#passFontSize').val() != "") {
        var addPt = $('#passFontSize').val().search("pt") == -1 ? "pt" : "";
        $(labelToInsert).css('font-size', $('#passFontSize').val() + addPt);
    }

    $(labelToInsert).prop("value", selectedSource);
    $(labelToInsert).prop("class", selectedSource);
    $(labelToInsert).prop("id", selectedSource);
    $(labelToInsert).css("text-overflow", "ellipsis ");
    if ($("#textSizeable").is(':checked')) {
        $(labelToInsert).resizable({
            containment: "#passLayout"
        });
    } else {
        $(labelToInsert).addClass("notResizable");
    }
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

function deletAddedElement(eventSelect) {
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


function createBarCodeImg(textToCreate, injectAfterLoad) {
    var imageToCreate = new Image();

    var headersToProcess = {
        requestType: "generateBar", textEnc: textToCreate
    };
    $.ajax({
        url: toPassMgmt,
        method: 'post',
        data: headersToProcess,
        success: function (returner) {
            resultOfGeneration = JSON.parse(returner);
            if (resultOfGeneration.Result == "Success") {
                if (injectAfterLoad == null) {
                    imageToCreate.src = 'data:image/png;base64,' + resultOfGeneration.Msg;

                } else {
                    $(injectAfterLoad).unbind('load');
                    $(injectAfterLoad).on('load', function () {
                        /* Fire your image resize code here */
                        convertDvToImg();
                    });
                    injectAfterLoad.setAttribute('src', 'data:image/png;base64,' + resultOfGeneration.Msg);
                }
                if (creatingPass) {
                    creatingPass = false;
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

function printPass() {
    qz.websocket.connect().then(function () {
        return qz.printers.find(printerName);               // Pass the printer name into the next Promise
    }).then(function (printer) {
        var config = qz.configs.create(printer, { colorType: 'grayscale' }); // Create a default config for the found printer format: 'base64',
        var rawDataFromImg = $("#imgPass")[0].toDataURL("image/png", 1).split(',')[1];
        var data = [
     {
         type: 'image',
         format: 'base64',
         data: rawDataFromImg
     }
        ];
        return qz.print(config, data);
    }).then(function () {
        endConnection();
    });

}

function endConnection() {
    if (qz.websocket.isActive()) {
        qz.websocket.disconnect().then(function () {
        }).catch(handleConnectionError);
    }
}