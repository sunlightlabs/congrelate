var mainTable;

function init() {

  prepare_table();
  
  var states = state_map();
  var state_elem = $('#filter_legislator_state');
  for (state in states)
    state_elem.append('<option value=\"' + state + '">' + states[state] + '</option>');

  // Add source data links
  $('a.source_form_link.inline_form').click(function() {
    var form_id = this.id.replace('_form_link', '');
    $('div.source_form:not(#' + form_id + ')').hide('medium');
    $('div#' + form_id).toggle('medium');
    return false;
  });
  $('a.source_form_link.popup_form').click(function() {
    var source_id = this.id.replace('_form_link', '');
    jQuery.facebox({ajax: '/' + source_id + '/form'});
    return false;
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
  $('select#filter_legislator_house').change(function() {      
    var filters = {house: "\\d+", senate: 'seat', all: ''};
    filter_column(filters[this.value], 2, true);
  });
  
  
  // column fields
  $('div.source_form input:checkbox, #legislator_form input:checkbox').change(toggle_checkbox);
  
  $(document).bind('reveal.facebox', function() {
    $("div#facebox table").show();
  });
}

function init_popup(source) {
  // for popups with a search field - the search form
  var popup_elem = 'div#' + source;
  $(popup_elem + ' form.search_name_form').submit(function() {
    return search_table(source, $('#search_name_field_' + source).val(), 1);
  });
  $(popup_elem + ' div.search_field input.search').focus(function() {this.value = '';})
  
  // For all popups - collecting the checked columns
  $(popup_elem + ' button.add_button').click(function() {
    popup_spinner_on();
    $(popup_elem + ' input:checked').each(function(i, box) {
      add_column(source, $(this).siblings('input:hidden').val());
    });
    popup_spinner_off();
    $(document).trigger('close.facebox');
  });

}

function search_table(source, q, page) {
  var popup_elem = 'div#' + source;
  var search_url = '/' + source + '/search?q=' + q + '&page=' + page;
  popup_spinner_on();
  $.ajax({
    success: function(data) {
      $('#search_name_table_' + source).html(data);
      $(popup_elem + ' tr.search_result td:not(td.' + source + '_box)').click(function() {    
        $(this).parent('tr').find('input:checkbox').click();
      });
      $(popup_elem + ' tr.search_result td.' + source + '_box input').click(function() {
        $(this).parent('td').parent('tr').toggleClass('selected');
      });
      $(popup_elem + ' div.page_button a').click(function() {
        return search_table(source, $('#roll_call_query').val(), $(this).siblings('input:hidden').val());
      });
      popup_spinner_off();
    },
    url: search_url
  });
  return false;
}

function toggle_checkbox() {
  var source, column;
  [source, column] = this.id.split('__');
  toggle_column(this.checked, source, column);
}

function add_column(source, column) {
  spinner_on();
  $.getJSON('/column.json', {source: source, column: column}, function(data) {
    var id = column_id(source, column);
    for (bioguide_id in data) {
      if (bioguide_id != 'title' && bioguide_id != 'header') {
        if (data[bioguide_id] == null)
          data[bioguide_id] = '';
        if (data['title'] == null)
          data['title'] = '';
        var row = $('tr#' + bioguide_id);
        if (row)
          $('tr#' + bioguide_id).append('<td class="' + id + '">' + data[bioguide_id] + '</tr>');
      }
    }
    $('#main_table tr.titles').append("<th class='" + id + "' title='" + escape_single_quotes(data['title']) + "'>" + data['header'] + "</th>");
    
    spinner_off();
    prepare_table();
  });
}

function filter_column(q, column, regex) {
  mainTable.fnFilter(q, column, !regex);
}

function remove_column(source, column) {
  spinner_on();
  $('.' + column_id(source, column)).remove();
  spinner_off();
}

function spinner_on() {$('#spinner').show();}
function spinner_off() {$('#spinner').hide();}

function popup_spinner_on() {$('.popup_spinner').show();}
function popup_spinner_off() {$('.popup_spinner').hide();}

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

function escape_single_quotes(string) {
  return string.replace(/\'/g, '\\\'');
}