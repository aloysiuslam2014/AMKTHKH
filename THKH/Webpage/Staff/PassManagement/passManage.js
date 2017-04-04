var toPassMgmt = './PassManagement/PassMgmtGateway.ashx';
var printerName = "POS";
var passGenerationFailed = "An error has occured while retrieveing the pass. ";
var ajaxPassconnectionFailure = "Ajax connection failed. Server filed not found or server offline. Please contact the administrator.";

var sPositions = {};
var level = 0;
var loadPassOnce = false;
var creatingPass = false;
/// <summary>Converts passclone div to canvas image</summary>
function convertDvToImg() {
    html2canvas($("#passClone"), {
        onrendered: function (canvas) {
            $(canvas).prop('id', 'imgPass');
            $("#userSuccess").append(canvas);
            $("#passClone").remove();
        }
    });
}

/// <summary>Convert from mm to px measurements</summary>
function convertMMtoPx(mmvalue) {
    //http://www.translatorscafe.com/unit-converter/typography/4-8/ convert to px from mm formula from here
    var convertedpx = (parseInt(mmvalue.replace('mm', '')) * 3.78) + "px";
    return convertedpx;
}

/// <summary>Gets pass state from the server and load it when pass management loads for the first time</summary>
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

/// <summary>Convert from mm to px measurements</summary>
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

/// <summary>Save current pass state to the server Database</summary>
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

/// <summary>Creates the pass and appends it to the target</summary>
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

/// <summary>Removes the event listeners and any remnant even listeners within the children.</summary>
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

/// <summary>Converts element into a draggable element</summary>
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

/// <summary>Change current pass dimensions</summary>
function changePassDimen(width, height) {
    $("#passLayout").css("width", convertMMtoPx(width));
    $("#passLayout").css("height", convertMMtoPx(height));
}

/// <summary>Sets pass dimensions to custom parameters</summary>
function customDimenstions() {
    var dimensionss = customSizePass.value.split("*");
    changePassDimen(dimensionss[0], dimensionss[1]);
}

/// <summary>Self explanatory</summary>
function toggleOrientation() {
    var width = $("#passLayout").width();
    var height = $("#passLayout").height();
    $("#passLayout").width(height);
    $("#passLayout").height(width);
}

/// <summary>Creates text based on a specific visitor field or a custom set text.</summary>
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

/// <summary>If the text to be added to the pass is a custom text show the custom textfield</summary>
function ifCustom() {
    var selectedSource = $("#source").val();
    if (selectedSource == "custom") {
        $("#customText").toggle(true);
    } else {
        $("#customText").toggle(false);
    }
}

/// <summary>Deletes an element from the pass based on right click</summary>
function deletAddedElement(eventSelect) {
    if (eventSelect.which == 3) {
        eventSelect.preventDefault();
        $(eventSelect.currentTarget).remove();
    }
}

/// <summary>Self explanatory</summary>
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

/// <summary>Creates the barcode image based on provided text. If injectAfterLoad is not null, append to it.</summary>
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
/// <summary>Creates te image from the canvas generated and add to the target 'me'.</summary>
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

/// <summary>Prints the pass using QZ tray's default certifiate. Recommended to replace with your own root certificate authority.</summary>
function printPass() {
    qz.security.setCertificatePromise(function (resolve, reject) { 
        // $.ajax("./PassManagement/signing/digital-certificate.txt").then(resolve, reject); Best to select your own certificate 
        //else 
        resolve("-----BEGIN CERTIFICATE-----\n" +
                "MIIFAzCCAuugAwIBAgICEAIwDQYJKoZIhvcNAQEFBQAwgZgxCzAJBgNVBAYTAlVT\n" +
                "MQswCQYDVQQIDAJOWTEbMBkGA1UECgwSUVogSW5kdXN0cmllcywgTExDMRswGQYD\n" +
                "VQQLDBJRWiBJbmR1c3RyaWVzLCBMTEMxGTAXBgNVBAMMEHF6aW5kdXN0cmllcy5j\n" +
                "b20xJzAlBgkqhkiG9w0BCQEWGHN1cHBvcnRAcXppbmR1c3RyaWVzLmNvbTAeFw0x\n" +
                "NTAzMTkwMjM4NDVaFw0yNTAzMTkwMjM4NDVaMHMxCzAJBgNVBAYTAkFBMRMwEQYD\n" +
                "VQQIDApTb21lIFN0YXRlMQ0wCwYDVQQKDAREZW1vMQ0wCwYDVQQLDAREZW1vMRIw\n" +
                "EAYDVQQDDAlsb2NhbGhvc3QxHTAbBgkqhkiG9w0BCQEWDnJvb3RAbG9jYWxob3N0\n" +
                "MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAtFzbBDRTDHHmlSVQLqjY\n" +
                "aoGax7ql3XgRGdhZlNEJPZDs5482ty34J4sI2ZK2yC8YkZ/x+WCSveUgDQIVJ8oK\n" +
                "D4jtAPxqHnfSr9RAbvB1GQoiYLxhfxEp/+zfB9dBKDTRZR2nJm/mMsavY2DnSzLp\n" +
                "t7PJOjt3BdtISRtGMRsWmRHRfy882msBxsYug22odnT1OdaJQ54bWJT5iJnceBV2\n" +
                "1oOqWSg5hU1MupZRxxHbzI61EpTLlxXJQ7YNSwwiDzjaxGrufxc4eZnzGQ1A8h1u\n" +
                "jTaG84S1MWvG7BfcPLW+sya+PkrQWMOCIgXrQnAsUgqQrgxQ8Ocq3G4X9UvBy5VR\n" +
                "CwIDAQABo3sweTAJBgNVHRMEAjAAMCwGCWCGSAGG+EIBDQQfFh1PcGVuU1NMIEdl\n" +
                "bmVyYXRlZCBDZXJ0aWZpY2F0ZTAdBgNVHQ4EFgQUpG420UhvfwAFMr+8vf3pJunQ\n" +
                "gH4wHwYDVR0jBBgwFoAUkKZQt4TUuepf8gWEE3hF6Kl1VFwwDQYJKoZIhvcNAQEF\n" +
                "BQADggIBAFXr6G1g7yYVHg6uGfh1nK2jhpKBAOA+OtZQLNHYlBgoAuRRNWdE9/v4\n" +
                "J/3Jeid2DAyihm2j92qsQJXkyxBgdTLG+ncILlRElXvG7IrOh3tq/TttdzLcMjaR\n" +
                "8w/AkVDLNL0z35shNXih2F9JlbNRGqbVhC7qZl+V1BITfx6mGc4ayke7C9Hm57X0\n" +
                "ak/NerAC/QXNs/bF17b+zsUt2ja5NVS8dDSC4JAkM1dD64Y26leYbPybB+FgOxFu\n" +
                "wou9gFxzwbdGLCGboi0lNLjEysHJBi90KjPUETbzMmoilHNJXw7egIo8yS5eq8RH\n" +
                "i2lS0GsQjYFMvplNVMATDXUPm9MKpCbZ7IlJ5eekhWqvErddcHbzCuUBkDZ7wX/j\n" +
                "unk/3DyXdTsSGuZk3/fLEsc4/YTujpAjVXiA1LCooQJ7SmNOpUa66TPz9O7Ufkng\n" +
                "+CoTSACmnlHdP7U9WLr5TYnmL9eoHwtb0hwENe1oFC5zClJoSX/7DRexSJfB7YBf\n" +
                "vn6JA2xy4C6PqximyCPisErNp85GUcZfo33Np1aywFv9H+a83rSUcV6kpE/jAZio\n" +
                "5qLpgIOisArj1HTM6goDWzKhLiR/AeG3IJvgbpr9Gr7uZmfFyQzUjvkJ9cybZRd+\n" +
                "G8azmpBBotmKsbtbAU/I/LVk8saeXznshOVVpDRYtVnjZeAneso7\n" +
                "-----END CERTIFICATE-----\n" +
                "--START INTERMEDIATE CERT--\n" +
                "-----BEGIN CERTIFICATE-----\n" +
                "MIIFEjCCA/qgAwIBAgICEAAwDQYJKoZIhvcNAQELBQAwgawxCzAJBgNVBAYTAlVT\n" +
                "MQswCQYDVQQIDAJOWTESMBAGA1UEBwwJQ2FuYXN0b3RhMRswGQYDVQQKDBJRWiBJ\n" +
                "bmR1c3RyaWVzLCBMTEMxGzAZBgNVBAsMElFaIEluZHVzdHJpZXMsIExMQzEZMBcG\n" +
                "A1UEAwwQcXppbmR1c3RyaWVzLmNvbTEnMCUGCSqGSIb3DQEJARYYc3VwcG9ydEBx\n" +
                "emluZHVzdHJpZXMuY29tMB4XDTE1MDMwMjAwNTAxOFoXDTM1MDMwMjAwNTAxOFow\n" +
                "gZgxCzAJBgNVBAYTAlVTMQswCQYDVQQIDAJOWTEbMBkGA1UECgwSUVogSW5kdXN0\n" +
                "cmllcywgTExDMRswGQYDVQQLDBJRWiBJbmR1c3RyaWVzLCBMTEMxGTAXBgNVBAMM\n" +
                "EHF6aW5kdXN0cmllcy5jb20xJzAlBgkqhkiG9w0BCQEWGHN1cHBvcnRAcXppbmR1\n" +
                "c3RyaWVzLmNvbTCCAiIwDQYJKoZIhvcNAQEBBQADggIPADCCAgoCggIBANTDgNLU\n" +
                "iohl/rQoZ2bTMHVEk1mA020LYhgfWjO0+GsLlbg5SvWVFWkv4ZgffuVRXLHrwz1H\n" +
                "YpMyo+Zh8ksJF9ssJWCwQGO5ciM6dmoryyB0VZHGY1blewdMuxieXP7Kr6XD3GRM\n" +
                "GAhEwTxjUzI3ksuRunX4IcnRXKYkg5pjs4nLEhXtIZWDLiXPUsyUAEq1U1qdL1AH\n" +
                "EtdK/L3zLATnhPB6ZiM+HzNG4aAPynSA38fpeeZ4R0tINMpFThwNgGUsxYKsP9kh\n" +
                "0gxGl8YHL6ZzC7BC8FXIB/0Wteng0+XLAVto56Pyxt7BdxtNVuVNNXgkCi9tMqVX\n" +
                "xOk3oIvODDt0UoQUZ/umUuoMuOLekYUpZVk4utCqXXlB4mVfS5/zWB6nVxFX8Io1\n" +
                "9FOiDLTwZVtBmzmeikzb6o1QLp9F2TAvlf8+DIGDOo0DpPQUtOUyLPCh5hBaDGFE\n" +
                "ZhE56qPCBiQIc4T2klWX/80C5NZnd/tJNxjyUyk7bjdDzhzT10CGRAsqxAnsjvMD\n" +
                "2KcMf3oXN4PNgyfpbfq2ipxJ1u777Gpbzyf0xoKwH9FYigmqfRH2N2pEdiYawKrX\n" +
                "6pyXzGM4cvQ5X1Yxf2x/+xdTLdVaLnZgwrdqwFYmDejGAldXlYDl3jbBHVM1v+uY\n" +
                "5ItGTjk+3vLrxmvGy5XFVG+8fF/xaVfo5TW5AgMBAAGjUDBOMB0GA1UdDgQWBBSQ\n" +
                "plC3hNS56l/yBYQTeEXoqXVUXDAfBgNVHSMEGDAWgBQDRcZNwPqOqQvagw9BpW0S\n" +
                "BkOpXjAMBgNVHRMEBTADAQH/MA0GCSqGSIb3DQEBCwUAA4IBAQAJIO8SiNr9jpLQ\n" +
                "eUsFUmbueoxyI5L+P5eV92ceVOJ2tAlBA13vzF1NWlpSlrMmQcVUE/K4D01qtr0k\n" +
                "gDs6LUHvj2XXLpyEogitbBgipkQpwCTJVfC9bWYBwEotC7Y8mVjjEV7uXAT71GKT\n" +
                "x8XlB9maf+BTZGgyoulA5pTYJ++7s/xX9gzSWCa+eXGcjguBtYYXaAjjAqFGRAvu\n" +
                "pz1yrDWcA6H94HeErJKUXBakS0Jm/V33JDuVXY+aZ8EQi2kV82aZbNdXll/R6iGw\n" +
                "2ur4rDErnHsiphBgZB71C5FD4cdfSONTsYxmPmyUb5T+KLUouxZ9B0Wh28ucc1Lp\n" +
                "rbO7BnjW\n" +
                "-----END CERTIFICATE-----\n");
    });

    qz.security.setSignaturePromise(function (toSign) {
        return function (resolve, reject) {
            //Preferred method - from server
            $.post("./PassManagement/signing/sign-message.php", { request: toSign }).then(resolve, reject);

            //Alternate method - unsigned
            resolve();
        };
    });

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

/// <summary>Ends the connection with Qztray.</summary>
function endConnection() {
    if (qz.websocket.isActive()) {
        qz.websocket.disconnect().then(function () {
        }).catch(handleConnectionError);
    }
}