$(document).ready(function(){

  function migrate_data(data){
    console.log('migrate_data start'); 
    // show processing message
    $('#create_migration_link').hide(300, function(){
      $('#create_migration_processing').show(300);
    })

    // start push
    console.log('posting to election map site'); 
    $.post(data.migration_url, {
      file_url: data.file_url,
      precincts_completed: data.precincts_completed,
      precincts_total: data.precincts_total,
      event_id: data.event_id,
      respond_to_url: data.respond_to_url
    }).done(function(response){
      console.log('finished!');
      console.log(response); 
      $('#create_migration_processing').hide(300, function(){
        $('#create_migration_success').show(300);
      })
    });
  }

  $('#create_migration').click(function(){
    console.log('create_migration click'); 
    $.ajax({
      url: "/en/admin/election_data/create_migration",
    }).done(function(resp) {
      //resp = {success, msg, data}
      console.log(resp);
      
      if (resp.success){
        migrate_data(resp.data);
      }
    });
  
    return false;
  });

});
