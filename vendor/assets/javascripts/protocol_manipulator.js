/* global $ */
//= require event
//= require magnifier



$(document).ready(function () {
  var
  img_id = "protocolimg", img = $("#" + img_id), img_wrapper = img.parent(), preview, lens, m;


  function rotate (deg, set) {
    deg = deg % 360;
    if(typeof set === "undefined") { set = false; }
    var tmp = "rotate(" + (deg + (set ? 0 : getCurrentRotationFixed(img_id))) + "deg)";
    img.css({ transform: tmp });
    preview.css({ transform: tmp });
    //lens.css({ transform: tmp });
    // restart_magnifier();
  }

  function bind () {
    preview = $("#" + img_id + "-large");
    if(!preview.length) {
      setTimeout(bind, 100);
      return;
    }

    lens = $("#" + img_id + "-lens");
    $("#protocol_move_up, #protocol_move_down").click(function () { img_wrapper.css({top: "+=" + (+$(this).attr("data-dir")) }); });
    $("#protocol_rotate_cw, #protocol_rotate_ccw").click(function () { rotate(+$(this).attr("data-dir")); }); // * $("#protocol_rotate_value").val();
    $("#protocol_flip").click(function () { rotate(180); });

    $("#protocol_rotate_reset").click(function () {
      img_wrapper.css({ top: 0 });
      rotate(0, true);
    });
    $(".protocol_controls_toggle").click(function () {
      $(this).toggleClass("expand");
      $(this).parent().toggleClass("cover");
    });
  }
  function attach_magnifier () {
    m.attach({
      thumb: "#" + img_id,
      large: img.attr("src"),
      largeWrapper: "magnifier-preview",
      zoom: 15,
      zoomable: true
    });

  }
  function main () {
    var evt = new Event();
    m = new Magnifier(evt);
    attach_magnifier();
    bind();
  }

  function getCurrentRotationFixed ( elid ) {
    var el = document.getElementById(elid);
    var st = window.getComputedStyle(el, null);
    var tr = st.getPropertyValue("-webkit-transform") ||
         st.getPropertyValue("-moz-transform") ||
         st.getPropertyValue("-ms-transform") ||
         st.getPropertyValue("-o-transform") ||
         st.getPropertyValue("transform") ||
         "fail...", angle = 0;

    if( tr !== "none") {
      //console.log("Matrix: " + tr);

      var values = tr.split("(")[1];
        values = values.split(")")[0];
        values = values.split(",");
      var a = values[0];
      var b = values[1];
      // var c = values[2];
      // var d = values[3];

      var radians = Math.atan2(b, a);
      if ( radians < 0 ) {
        radians += (2 * Math.PI);
      }
      angle = Math.round( radians * (180/Math.PI));

    }
    return angle;
  }
  main();
});
