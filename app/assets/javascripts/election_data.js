$(document).ready(function(){

  
  $('#create_migration').click(function(){
    console.log('create_migration click'); 
    $.ajax({
      url: "/en/admin/election_data/create_migration",
    }).done(function(resp) {
      //resp = {success, msg, data}
      console.log(resp);
      
      if (resp.success){
        // show processing message
        $('#create_migration_link').hide(300, function(){
          $('#create_migration_processing').show(300);
        })

        // start push
        console.log('posting to election map site'); 
        $.ajax({
          url: resp.data.migration_url,
          data: {
            file_url: resp.data.file_url,
            precincts_completed: resp.data.precincts_completed,
            precincts_total: resp.data.precincts_total,
            event_id: resp.data.event_id,
            respond_to_url: resp.data.respond_to_url
          }
        }).done(function(resp){
          console.log('back from map site'); 
          if (resp.success){
            // show success message
            $('#create_migration_processing').hide(300, function(){
              $('#create_migration_success').show(300);
            })
          } else {
            // show success message
            $('#create_migration_processing').hide(300, function(){
              $('#create_migration_error').show(300);
            })
          }
          // save the migration notification
          $.ajax({
            url: gon.notification_url,
            data: {
              file_url: resp.file_url,
              success: resp.success,
              msg: resp.msg
            }
          }).done(function(resp){
            console.log('all done!');
          });
        });
      }
    });
  
    return false;
  });

});
