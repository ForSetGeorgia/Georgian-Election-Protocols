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


  $('form.election input[name="election[is_local_majoritarian]"]').on('change', function(){
    // if the selected value is true, then custom shapes must also be true
    if ($('form.election input[name="election[is_local_majoritarian]"]:checked').val() == 'true'){
      $('form.election input#election_has_custom_shape_levels_true').prop('checked', true);
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


  // if this is a new form, copy the english name into this field
  if($('form.election input#election_tmp_analysis_table_name').length > 0){

    $('#election_election_translations_attributes_0_name').on('change', function(){
      $('#election_tmp_analysis_table_name').val($(this).val().substring(0,31));
    });

    // in case there is a value in the name when the form loads
    $('#election_tmp_analysis_table_name').val($('#election_election_translations_attributes_0_name').val().substring(0,31));
  }


});