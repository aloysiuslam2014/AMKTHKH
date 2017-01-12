$(function () {
   

    $(document).ready(function () {// once ready then we toglle based  on ajax calls
        $("#loadingGif").toggle(false);

        $(document).ajaxSuccess(function () {
            $("#loadingGif").toggle(true);
        });
        //or...
        $(document).ajaxComplete(function () {
            $("#loadingGif").toggle(false);
        });
    });
});