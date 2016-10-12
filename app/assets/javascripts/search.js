
$(document).ready(function(){
  $.extend( $.fn.dataTableExt.oStdClasses, {
      "sWrapper": "dataTables_wrapper form-inline"
  });

  // to be able to sort the jquery datatable build in the function below
  jQuery.fn.dataTableExt.oSort['formatted-num-asc'] = function ( a, b ) {
    var x = a.match(/\d/) ? a.replace( /[^\d\-\.]/g, "" ) : 0;
    var y = b.match(/\d/) ? b.replace( /[^\d\-\.]/g, "" ) : 0;
    return parseFloat(x) - parseFloat(y);
  };

	jQuery.fn.dataTableExt.oSort['formatted-num-desc'] = function ( a, b ) {
    var x = a.match(/\d/) ? a.replace( /[^\d\-\.]/g, "" ) : 0;
    var y = b.match(/\d/) ? b.replace( /[^\d\-\.]/g, "" ) : 0;
    return parseFloat(y) - parseFloat(x);
  };


/*
  $('#users-datatable').dataTable({
    "sDom": "<'row-fluid'<'span6'l><'span6'f>r>t<'row-fluid'<'span6'i><'span6'p>>",
    "sPaginationType": "bootstrap",
    "bJQueryUI": true,
    "bProcessing": true,
    "bServerSide": true,
    "bDestroy": true,
    "bAutoWidth": false,
    "sAjaxSource": $('#users-datatable').data('source'),
    "oLanguage": {
      "sUrl": gon.datatable_i18n_url
    },
    "aaSorting": [[2, 'desc']]
  });
*/

  var col_sort = new Array($('#users-datatable > thead > tr > th').length);
  for(var i=0;i<$('#users-datatable > thead > tr > th').length;i++){
    col_sort[i] = {"sType": "formatted-num" };
  }

  $('#users-datatable').dataTable({
    "sDom": "<'row-fluid'<'span6'l><'span6'f>r>t<'row-fluid'<'span6'i><'span6'p>>",
    "sPaginationType": "bootstrap",
    "bJQueryUI": true,
    "bProcessing": true,
    "bAutoWidth": true,
    "aoColumns": col_sort,
    "oLanguage": {
      "sUrl": gon.datatable_i18n_url
    }
  });

  col_sort = new Array($('.overall_stats_by_district > thead > tr > th').length);
  for(var i=0;i<$('.overall_stats_by_district > thead > tr > th').length;i++){
    col_sort[i] = {"sType": "formatted-num" };
  }

  $('.overall_stats_by_district').dataTable({
    "sDom": "<'row-fluid'<'span6'l><'span6'f>r>t<'row-fluid'<'span6'i><'span6'p>>",
    "sPaginationType": "bootstrap",
    "bJQueryUI": true,
    "bProcessing": true,
    "bAutoWidth": true,
    // "aoColumns": col_sort,
    "oLanguage": {
      "sUrl": gon.datatable_i18n_url
    }
  });


  $('#download_elections').dataTable({
    "sDom": "<'row-fluid'<'span6'l><'span6'f>r>t<'row-fluid'<'span6'i><'span6'p>>",
    "sPaginationType": "bootstrap",
    "bJQueryUI": true,
    "bProcessing": true,
    "bAutoWidth": true,
    "oLanguage": {
      "sUrl": gon.datatable_i18n_url
    },
    "aaSorting": [[2, 'desc']],
    "aoColumnDefs": [
      {
         "bSortable": false,
         "aTargets": [ 0 ]
      }
    ]
  });



  $('table.migration_records').dataTable({
    "sDom": "<'row-fluid'<'span6'l><'span6'f>r>t<'row-fluid'<'span6'i><'span6'p>>",
    "sPaginationType": "bootstrap",
    "bJQueryUI": true,
    "bProcessing": true,
    "bAutoWidth": true,
    "oLanguage": {
      "sUrl": gon.datatable_i18n_url
    },
    "aaSorting": [[0, 'desc']]
  });

  $('table.annulled').dataTable({
    "sDom": "<'row-fluid'<'span6'l><'span6'f>r>t<'row-fluid'<'span6'i><'span6'p>>",
    "sPaginationType": "bootstrap",
    "bJQueryUI": true,
    "bProcessing": true,
    "bAutoWidth": true,
    "oLanguage": {
      "sUrl": gon.datatable_i18n_url
    },
    "aaSorting": [[1, 'asc']],
    "aoColumnDefs": [
      {
         "bSortable": false,
         "aTargets": [ 0 ]
      }
    ]
  });

  $('table.amendments').dataTable({
    "sDom": "<'row-fluid'<'span6'l><'span6'f>r>t<'row-fluid'<'span6'i><'span6'p>>",
    "sPaginationType": "bootstrap",
    "bJQueryUI": true,
    "bProcessing": true,
    "bAutoWidth": true,
    "oLanguage": {
      "sUrl": gon.datatable_i18n_url
    },
    "aaSorting": [[1, 'asc']],
    "aoColumnDefs": [
      {
         "bSortable": false,
         "aTargets": [ 0 ]
      }
    ]
  });



});
