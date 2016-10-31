$(document).ready(function(){
  if ($('#moderate table.moderate').length > 0){

    // when enter notes, save it
    $('table.moderate').on('change', '.moderation-notes textarea', function(){
      var $this = $(this);
      $.ajax({
        type: "POST",
        url: gon.moderate_notes_url,
        data: {id: $(this).data('id'), user_id: $(this).data('user_id'), notes: $(this).val()}
      })
      .done(function(data) {
        console.log('success!');
        console.log(data);
        // add time
        $this.closest('tr').find('td.moderation-updated-at span').fadeOut(function(){
          $(this).html(data.response.time);
          $(this).fadeIn();
        });
      })
      .fail(function(data) {
        console.log('error!');
        console.log(data);
      })

      return false;
    });

    // when select moderation type, save it
    $('table.moderate').on('click', 'a.moderate-record', function(){
      var $this = $(this);
      $.ajax({
        type: "POST",
        url: gon.moderate_record_url,
        data: {id: $(this).data('id'), user_id: $(this).data('user_id'), action_to_take: $(this).data('action_to_take')}
      })
      .done(function(data) {
        console.log('success!');
        console.log(data);
        // add status
        $this.closest('tr').find('td.moderation-status span').fadeOut(function(){
          $(this).html(data.response.status);
          $(this).fadeIn();
        });
        // add time
        $this.closest('tr').find('td.moderation-updated-at span').fadeOut(function(){
          $(this).html(data.response.time);
          $(this).fadeIn();
        });

        // hide the drop down if this is not cec
        if ($this.data('action_to_take') != 'contact_cec'){
          $this.closest('.dropdown').fadeOut();
        }else{
          $this.closest('.dropdown').removeClass('open');
        }

      })
      .fail(function(data) {
        console.log('error!');
        console.log(data);
      })

      return false;
    })

  }
});
