
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

  // col_sort = new Array($('.overall_stats_by_district > thead > tr > th').length);
  // for(var i=0;i<$('.overall_stats_by_district > thead > tr > th').length;i++){
  //   col_sort[i] = {"sType": "formatted-num" };
  // }

  $('.overall_stats_by_district').dataTable({
    "sDom": "<'row-fluid'<'span6'l><'span6'f>r>t<'row-fluid'<'span6'i><'span6'p>>",
    "sPaginationType": "bootstrap",
    "bJQueryUI": true,
    "bProcessing": true,
    "bAutoWidth": true,
    // "aoColumns": col_sort,
    "aoColumnDefs": [
      { "sType": "formatted-num", "aTargets": 'num-sort' }
    ],
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

  $('table.supplemental_documents').dataTable({
    "sDom": "<'row-fluid'<'span6'l><'span6'f>r>t<'row-fluid'<'span6'i><'span6'p>>",
    "sPaginationType": "bootstrap",
    "bJQueryUI": true,
    "bProcessing": true,
    "bAutoWidth": true,
    // "aoColumns": col_sort,
    "aoColumnDefs": [
      { "sType": "formatted-num", "aTargets": [ 1,2,3,4,6,8,10 ] }
    ],
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

  col_sort = new Array($('table.district_summaries > thead > tr > th').length);
  for(var i=0;i<$('table.district_summaries > thead > tr > th').length;i++){
    col_sort[i] = {"sType": "formatted-num" };
  }

  $('table.district_summaries').dataTable({
    "sDom": "<'row-fluid'<'span6'l><'span6'f>r>t<'row-fluid'<'span6'i><'span6'p>>",
    "sPaginationType": "bootstrap",
    "bJQueryUI": true,
    "bProcessing": true,
    "bAutoWidth": true,
    "aoColumns": col_sort,
    "oLanguage": {
      "sUrl": gon.datatable_i18n_url
    },
    "aaSorting": [[0, 'asc']]
  });



  // the moderation table uses textbox filters
  // taken from https://legacy.datatables.net/release-datatables/extras/ColReorder/col_filter.html
  var moderationTable;
  var $moderationFilters = $("table.moderate thead input");
  /* Add the events etc before DataTables hides a column */
  $moderationFilters.keyup( function () {
    /* Filter on the column (the index) of this element */
    // have to +1 the index for the first column does not have an input field
    moderationTable.fnFilter( this.value, moderationTable.oApi._fnVisibleToColumnIndex(
      moderationTable.fnSettings(), $moderationFilters.index(this)+1 ) );
  });

  /*
   * Support functions to provide a little bit of 'user friendlyness' to the textboxes
   */
  $moderationFilters.each( function (i) {
    this.initVal = this.value;
  });

  $moderationFilters.focus( function () {
    if ( this.className == "search_init" )
    {
      this.className = "";
      this.value = "";
    }
  });

  $moderationFilters.blur( function (i) {
    if ( this.value == "" )
    {
      this.className = "search_init";
      this.value = this.initVal;
    }
  });

  moderationTable = $('table.moderate').dataTable({
    "sDom": "<'row-fluid'<'span6'l><'span6'f>r>t<'row-fluid'<'span6'i><'span6'p>>",
    "sPaginationType": "bootstrap",
    "bJQueryUI": true,
    "bProcessing": true,
    "bAutoWidth": true,
    "aoColumnDefs": [
      { "sType": "formatted-num", "aTargets": 'num-sort' },
      {
         "bSortable": false,
         "aTargets": [ 0 ]
      }
    ],
    "oLanguage": {
      "sUrl": gon.datatable_i18n_url
    },
    "aaSorting": [[1, 'desc']],
    "bSortCellsTop": true
  });


  // the say-what table uses textbox filters
  // taken from https://legacy.datatables.net/release-datatables/extras/ColReorder/col_filter.html
  var saywhatTable;
  var $saywhatFilters = $("table.say-what thead input");
  /* Add the events etc before DataTables hides a column */
  $saywhatFilters.keyup( function () {
    /* Filter on the column (the index) of this element */
    // have to +1 the index for the first column does not have an input field
    saywhatTable.fnFilter( this.value, saywhatTable.oApi._fnVisibleToColumnIndex(
      saywhatTable.fnSettings(), $saywhatFilters.index(this)+1 ) );
  });

  /*
   * Support functions to provide a little bit of 'user friendlyness' to the textboxes
   */
  $saywhatFilters.each( function (i) {
    this.initVal = this.value;
  });

  $saywhatFilters.focus( function () {
    if ( this.className == "search_init" )
    {
      this.className = "";
      this.value = "";
    }
  });

  $saywhatFilters.blur( function (i) {
    if ( this.value == "" )
    {
      this.className = "search_init";
      this.value = this.initVal;
    }
  });

  saywhatTable = $('table.say-what').dataTable({
    "sDom": "<'row-fluid'<'span6'l><'span6'f>r>t<'row-fluid'<'span6'i><'span6'p>>",
    "sPaginationType": "bootstrap",
    "bJQueryUI": true,
    "bProcessing": true,
    "bAutoWidth": true,
    "aoColumnDefs": [
      { "sType": "formatted-num", "aTargets": 'num-sort' },
      {
         "bSortable": false,
         "aTargets": [ 0 ]
      }
    ],
    "oLanguage": {
      "sUrl": gon.datatable_i18n_url
    },
    "aaSorting": [[1, 'desc']],
    "bSortCellsTop": true
  });




  $('table.needs_clarification').dataTable({
    "sDom": "<'row-fluid'<'span6'l><'span6'f>r>t<'row-fluid'<'span6'i><'span6'p>>",
    "sPaginationType": "bootstrap",
    "bJQueryUI": true,
    "bProcessing": true,
    "bAutoWidth": true,
    "aoColumnDefs": [
      { "sType": "formatted-num", "aTargets": 'num-sort' },
      {
         "bSortable": false,
         "aTargets": [ 0 ]
      }
    ],
    "oLanguage": {
      "sUrl": gon.datatable_i18n_url
    },
    "aaSorting": [[1, 'desc']]
  });



});
