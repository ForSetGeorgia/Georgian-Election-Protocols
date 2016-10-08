/* global $ */
//= require event
//= require magnifier



$(document).ready(function () {
  var
  img_id = "protocolimg", img = $("#" + img_id), img_wrapper = img.parent(), preview, lens, m;


  function rotate (deg, set) {
    if(typeof set === "undefined") { set = false; }
    deg = (deg + (set ? 0 : getCurrentRotationFixed(img_id)));
    deg = deg % 360;
    var tmp = transform_rotate(deg);
    img.css(tmp);
    preview.css(tmp);
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
      angle = Math.round10( radians * (180/Math.PI), -1);

    }
    return angle;
  }
  // Closure
  (function () {
    /**
     * Decimal adjustment of a number.
     *
     * @param {String}  type  The type of adjustment.
     * @param {Number}  value The number.
     * @param {Integer} exp   The exponent (the 10 logarithm of the adjustment base).
     * @returns {Number} The adjusted value.
     */
    function decimalAdjust(type, value, exp) {
      // If the exp is undefined or zero...
      if (typeof exp === 'undefined' || +exp === 0) {
        return Math[type](value);
      }
      value = +value;
      exp = +exp;
      // If the value is not a number or the exp is not an integer...
      if (isNaN(value) || !(typeof exp === 'number' && exp % 1 === 0)) {
        return NaN;
      }
      // Shift
      value = value.toString().split('e');
      value = Math[type](+(value[0] + 'e' + (value[1] ? (+value[1] - exp) : -exp)));
      // Shift back
      value = value.toString().split('e');
      return +(value[0] + 'e' + (value[1] ? (+value[1] + exp) : exp));
    }

    // Decimal round
    if (!Math.round10) {
      Math.round10 = function(value, exp) {
        return decimalAdjust('round', value, exp);
      };
    }
    // Decimal floor
    if (!Math.floor10) {
      Math.floor10 = function(value, exp) {
        return decimalAdjust('floor', value, exp);
      };
    }
    // Decimal ceil
    if (!Math.ceil10) {
      Math.ceil10 = function(value, exp) {
        return decimalAdjust('ceil', value, exp);
      };
    }
  })();

  function transform_rotate (deg) {
    var tmp = "rotate(" + deg + "deg)", obj = {};
    obj["-webkit-transform"] = tmp;
    obj["-ms-transform"] = tmp;
    obj["transform"] = tmp;
    return obj;
  }

  main();
});
