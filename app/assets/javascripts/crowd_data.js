$(function ()
{




  $('input.error').next('.help-inline').replaceWith(function ()
  {
    return '<img src="/assets/exclamation.png" class="error-icon" alt="error" data-message="' + $(this).text() + '" />';
  });

  var error_icons = $('img.error-icon');

  if (error_icons.length)
  {

    $('body').append('<div id="error-icon-tooltip"></div>');
    var tooltip = $('#error-icon-tooltip');

    error_icons.hover(function ()
    {
      tooltip.html($(this).data('message'));
      tooltip.css({
        visibility: 'visible',
        top: $(this).offset().top - tooltip.outerHeight() - 7,
        left: $(this).offset().left + $(this).outerWidth() / 2 - tooltip.outerWidth() / 2
      });
    }, function ()
    {
      tooltip.css('visibility', 'hidden');
    });

  }


  var votesum = $('#votesum');
  if (votesum.length)
  {
    var vch = {s: votesum.children('.s'), f: votesum.children('.f')};

    var input = $('#crowd_datum_invalid_ballots_submitted'),
    offset = input.offset();
    votesum.css({left: offset.left + input.outerWidth(), top: offset.top});

    var partyinputs = $('input[id*="crowd_datum_party_"]').add(input);
    partyinputs.keyup(function ()
    {
      var sum = 0;
      partyinputs.each(function ()
      {
        sum += +$(this).val();
      });
      vch.s[0].innerHTML = sum;
      check_values();
    });

    $('#crowd_datum_ballots_signed_for').keyup(function ()
    {
      console.log($(this).val());
      vch.f[0].innerHTML = $(this).val();
      check_values();
    });

    function check_values ()
    {
      if (vch.s[0].innerHTML == vch.f[0].innerHTML)
      {
        votesum.addClass('same');
      }
      else
      {
        votesum.removeClass('same');
      }
    }
  }


/*
  if ($('#protocolimg').length)
  {
    var img = new Image();
    img.onload = function ()
    {
      if (img.height < 1100)
      {
        $('#protocolimg').addClass('low');
      }
    }
    img.src = $('#protocolimg').attr('src');
  }
*/







});
