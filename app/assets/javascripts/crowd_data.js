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








});
