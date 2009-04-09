var mainTable;

var GB_ANIMATION = true;
$(document).ready(function(){

  $("td.delete a").click(function(){
    $(this).parent().parent().fadeOut("slow", function () {
      $(this).remove();
      $("table tbody tr").removeClass("odd");
      $("table tbody tr").removeClass("even");
      $("table tbody tr").each(function (i) {
        if (i % 2 == 1)
          $(this).addClass("even");
        else
          $(this).addClass("odd");     
      });
    });
  });
  
  $("a#addLegislators").click(function(){
    $("div#addLegislatorsForm").toggle("slow");
  });
  
  $("a#addCensus").click(function(){
    $("div#censusData").toggle("slow");
  });
  
  $('input#name').click(function() {
    this.value = '';
  });
  
  $("a#addVotes").facebox();
  $(document).bind('reveal.facebox', function() {
    $("div#facebox table").show();
    $("div#facebox div.content a#bustedLink").click(function() {
      $(document).trigger('close.facebox');

      //This is whatever you want the button/link/whatever to do.  Submit a form, pull back data, adjust the DOM, etc.
      $("table").hide("slow");
    });
  });
});

function add_column(source, column) {
  spinner_on();
  $.getJSON('/column.json', {source: source, column: column}, function(data) {
    var id = column_id(source, column);
    for (bioguide_id in data) {
      if (bioguide_id != 'title' && bioguide_id != 'header') {
        var row = $('tr#' + bioguide_id);
        if (row)
          $('tr#' + bioguide_id).append('<td class="' + id + '">' + data[bioguide_id] + '</tr>');
      }
    }
    $('tr#titles').append('<th class="' + id + '">' + data['title'] + '</th>');
    spinner_off();
    prepare_table();
  });
}

function remove_column(source, column) {
  spinner_on();
  $('.' + column_id(source, column)).remove();
  spinner_off();
}

function spinner_on() {$('#spinner').show();}
function spinner_off() {$('#spinner').hide();}

function toggle_column(checked, source, column) {
  if (checked)
    add_column(source, column);
  else
    remove_column(source, column);
}

function column_id(source, column) {
  return source + '_' + column;
}

function prepare_table() {
  mainTable = $('#main_table').dataTable({
    bProcessing: true,
    bPaginate: false,
    bInfo: false,
    bFilter: false,
    bProcessing: false,
    aaSorting: [[1, 'asc'], [2, 'asc']]
  });
}