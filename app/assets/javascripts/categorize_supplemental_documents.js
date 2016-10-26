$(document).ready(function(){
  if ($('form.supplemental_document').length > 0){

    $('.document-selection').on('click', 'a', function(){
      // get the name and update the form field value for that name to 1
      // then submit the form
      $("input#supplemental_document_" + $(this).data('name')).val(1);
      $(this).closest('form').submit();
    })

  }
});
