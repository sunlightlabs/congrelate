var mainTable;
var GB_ANIMATION = true;

function init() {

  prepare_table();
  
  var states = state_map();
  var state_elem = $('#filter_legislator_state');
  for (state in states)
    state_elem.append('<option value=\"' + state + '">' + states[state] + '</option>');

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
  
  // Add source data links
  $("a.source_form_link").click(function() {
    $("div#" + this.id.replace("_link", "")).toggle("slow");
  });
  
  // filter fields
  $('input#filter_legislator_name').focus(function() {
    if (this.value == 'By Name')
      this.value = '';
  }).blur(function() {
    if (this.value == '')
      this.value = 'By Name';
  }).keyup(function() {
    filter_column(this.value, 0);
  });
  $('select#filter_legislator_state').change(function() {
    filter_column(this.value, 1);
  });
  
  // column fields
  $('div.source_form input:checkbox, #legislator_form input:checkbox').change(function() {
    var source, column;
    [source, column] = this.id.split("_");
    toggle_column(this.checked, source, column);
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
}

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

function filter_column(q, column) {
  mainTable.fnFilter(q, column);
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
    oLanguage: {sZeroRecords: "No matching legislators."},
    aaSorting: [[1, 'asc'], [2, 'asc']]
  });
}

function state_map() {
  return {
    AL: "Alabama",
    AK: "Alaska",
    AZ: "Arizona",
    AR: "Arkansas",
    CA: "California",
    CO: "Colorado",
    CT: "Connecticut",
    DE: "Delaware",
    DC: "District of Columbia",
    FL: "Florida",
    GA: "Georgia",
    HI: "Hawaii",
    ID: "Idaho",
    IL: "Illinois",
    IN: "Indiana",
    IA: "Iowa",
    KS: "Kansas",
    KY: "Kentucky",
    LA: "Louisiana",
    ME: "Maine",
    MD: "Maryland",
    MA: "Massachusetts",
    MI: "Michigan",
    MN: "Minnesota",
    MS: "Mississippi",
    MO: "Missouri",
    MT: "Montana",
    NE: "Nebraska",
    NV: "Nevada",
    NH: "New Hampshire",
    NJ: "New Jersey",
    NM: "New Mexico",
    NY: "New York",
    NC: "North Carolina",
    ND: "North Dakota",
    OH: "Ohio",
    OK: "Oklahoma",
    OR: "Oregon",
    PA: "Pennsylvania",
    PR: "Puerto Rico",
    RI: "Rhode Island",
    SC: "South Carolina",
    SD: "South Dakota",
    TN: "Tennessee",
    TX: "Texas",
    UT: "Utah",
    VT: "Vermont",
    VA: "Virginia",
    WA: "Washington",
    WV: "West Virginia",
    WI: "Wisconsin",
    WY: "Wyoming"
  }
}