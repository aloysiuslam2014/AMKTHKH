// Load & Populate User List
function initializeUsers() {
    var headersToProcess = {
        pName: pName, bedno: bedno, requestType: "loadUsers"
    };
    $.ajax({
        url: './userManagement.ashx',
        method: 'post',
        data: headersToProcess,


        success: function (returner) {
            var resultOfGeneration = JSON.parse(returner);
            
        },
        error: function (err) {
            alert("Error: " + err.msg + ". Please contact the adminsitrator.");
        },
    });
}

// Update User Data
function updateUser() {
    var headersToProcess = {
        pName: pName, bedno: bedno, requestType: "updateUser"
    };
    $.ajax({
        url: './userManagement.ashx',
        method: 'post',
        data: headersToProcess,


        success: function (returner) {
            var resultOfGeneration = JSON.parse(returner);

        },
        error: function (err) {
            alert("Error: " + err.msg + ". Please contact the adminsitrator.");
        },
    });
}

// Delete Selected User
function deleteUser() {
    var headersToProcess = {
        pName: pName, bedno: bedno, requestType: "deleteUser"
    };
    $.ajax({
        url: './userManagement.ashx',
        method: 'post',
        data: headersToProcess,


        success: function (returner) {
            var resultOfGeneration = JSON.parse(returner);

        },
        error: function (err) {
            alert("Error: " + err.msg + ". Please contact the adminsitrator.");
        },
    });
}

// Add new user
function addUser() {
    var headersToProcess = {
        pName: pName, bedno: bedno, requestType: "addUser"
    };
    $.ajax({
        url: './userManagement.ashx',
        method: 'post',
        data: headersToProcess,


        success: function (returner) {
            var resultOfGeneration = JSON.parse(returner);

        },
        error: function (err) {
            alert("Error: " + err.msg + ". Please contact the adminsitrator.");
        },
    });
}
