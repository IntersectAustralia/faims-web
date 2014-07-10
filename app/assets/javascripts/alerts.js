$(window).load(function () {

    $(function () {
        var alert = $('.alert');
        if (alert.length > 0) {
            alert.slideDown();

            if (!alert.hasClass("alert-error")) {
                var alerttimer = window.setTimeout(function () {
                    alert.slideUp();
                }, 9000);
            }
            $(".alert").click(function () {
                window.clearTimeout(alerttimer);
                alert.slideUp();
            });
        }
    });

});

