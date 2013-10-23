
$(document).ready(function(){

  $('#overall_stats_by_district').dataTable({
    "sDom": "<'row-fluid'<'span6'l><'span6'f>r>t<'row-fluid'<'span6'i><'span6'p>>",
    "sPaginationType": "bootstrap",
    "bJQueryUI": true,
    "bProcessing": true,
    "bAutoWidth": true,
    "oLanguage": {
      "sUrl": gon.datatable_i18n_url
    },
    "aaSorting": [[2, 'asc']]
  });



});
