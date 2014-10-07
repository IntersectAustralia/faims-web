/*
  DP Toast jQuery Plugin, Version 1.1
  Copyright (C) Dustin Poissant 2014
  See http://htmlpreview.github.io/?https://github.com/dustinpoissant/jquery.dpToast/blob/master/License.html
  for more information reguarding usage.
*/
;(function($){
  $.toast = function(){
    var container;
    if( $("#dp-toasts").length < 1){
      $("body").append("<div id='dp-toasts'></div>");
      container = $("#dp-toasts");
      container[0].count = 0;
      container.css({
        position: "fixed",
        display: "inline-block",
        top: "8vh",
        left: "0px",
        width: "100vw",
        textAlign: "center",
        margin: "0 auto"
      });
    } else {
      container = $("#dp-toasts");
    }
    var toastNumber = container[0].count +1;
    var message = "Error: No Toast Message";
    var timeout = 3000;
    var type = "info"
    for(var i=0; i<arguments.length; i++){
      if(typeof(arguments[i]) == "string" && arguments[i].length > 0 && i == 0) message = arguments[i];
      else if(typeof(arguments[i]) == "number") timeout = arguments[i];
      else if(typeof(arguments[i]) == "string" && arguments[i].length > 0 && i == 2 ) type = arguments[i];
    }
    container.prepend("<div class='dp-toast dp-toast-"+toastNumber+" alert alert-"+type+"'>"+message+"</div><div class='dp-toast-"+toastNumber+"-br'></div>");
    var toast = $(".dp-toast-"+toastNumber);
    toast.css({
      display: "inline-block",
      padding: "10px 16px",
      borderRadius: "3px",
      margin: "5px auto"
    });
    toast.hide().fadeIn();
    window.setTimeout(function(){
      toast.fadeOut(function(){
        toast.add(".toast-"+toastNumber+"-br").remove();
        if(container.children().size() == 0 ) container.remove();
      });
    }, timeout);
    container[0].count = toastNumber;
  }
}(jQuery));