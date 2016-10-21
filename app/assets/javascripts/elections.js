$(document).ready(function(){
  $('form.election input[name="election[parties_same_for_all_districts]"]').on('change', function(){
    // if the selected value is true, then show the file field,
    // else hide it
    if ($('form.election input[name="election[parties_same_for_all_districts]"]:checked').val() == 'true'){
      $('#election_party_district_file_input').fadeOut();
    }else{
      $('#election_party_district_file_input').fadeIn();
    }

  });


  if($('form.election').length > 0){
    // load the date pickers
    $('#election_election_at').datepicker({
        dateFormat: 'yy-mm-dd',
    });

    if (gon.election_at !== undefined &&
        gon.election_at.length > 0)
    {
      $("#election_election_at").datepicker("setDate", new Date(gon.election_at));
    }
  }

});