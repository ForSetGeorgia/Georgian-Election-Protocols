$(document).ready(function(){
  if ($('#moderate table.moderate').length > 0){

    $('table.moderate').on('click', 'a.moderate-record', function(){

    $.ajax({
      type: "POST",
      url: gon.moderate_record_url,
      data: {id: $(this).data('id'), user_id: $(this).data('user_id'), action_to_take: $(this).data('action_to_take')}
    })
    .done(function() {
      alert( "second success" );
    })
    .fail(function() {
      alert( "error" );
    })
    .always(function() {
      alert( "finished" );
    });

      return false;
    })

  }
});
