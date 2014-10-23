$(window).load(function () {

    $(function () {
        var alerts = $(".alert");
        alerts.each(function() {
            var alert = $(this);
            alert.slideDown();

            var alerttimer;
            if (alert.hasClass("alert-success")) {
                alerttimer = window.setTimeout(function () {
                    alert.slideUp();
                }, 9000);
            }

            alert.click(function () {
                if (!alert.hasClass("alert-info")) {
                    window.clearTimeout(alerttimer);
                    alert.slideUp();
                }
            });
        })
    });

});

