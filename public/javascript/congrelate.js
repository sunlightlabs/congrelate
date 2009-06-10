var mainTable;

var current_columns = {
  'legislator[name]': 1,
  'legislator[state]': 1,
  'legislator[district]': 1
};

var current_filter = "";

function init() {

  prepare_table();
  
    // Add source data links
  $('a.source_form_link').click(function() {
    var source_id = this.id.replace('_form_link', '');
    jQuery.facebox({ajax: '/' + source_id + '/form'});
    return false;
  });
  
  // filter fields
  $('input#filter_field').keyup(function() {
    if (this.zid) clearTimeout(this.zid);
    var filter = this.value;
    
    this.zid = setTimeout(function() {
      filter_table(strip_search(filter));
      if ($('#main_table tr.legislator:visible').size() == 0) {
        $('div.no_results').show();
      } else {
        $('div.no_results').hide();
      }
    }, 500);
    current_filter = filter;
    update_links();
    
  }).focus(function() {
    if (!$(this).hasClass('activated')) {
      $(this).addClass('activated');
      $(this).val('');
    }
  });
  if ($('input#filter_field').hasClass('activated'))
    $('input#filter_field').keyup();
  
  // download links
  update_links();
  
  // filter links
  filter_links();
  
  // table functions
  $('tr.titles th a.remove').click(function() {
    var source = $(this).siblings('input.source').val();
    var column = $(this).siblings('input.column').val();
    remove_column(source, column);
  });
  
  $(document).bind('reveal.facebox', function() {
    $("div#facebox table").show();
  });
}

function init_source_form(source) {
  // for popups with a search field - the search form
  var popup_elem = 'div#' + source;
  $(popup_elem + ' form.search_name_form').submit(function() {
    return search_table(source, $('#search_name_field_' + source).val(), 1);
  });
  $(popup_elem + ' div.search_field input.search').focus(function() {this.value = '';})
  
  // for popups with a grid of checkboxes
  $(popup_elem + ' table.grid td input:checkbox').click(function() {
    $(this).parents('table.grid td').toggleClass('selected');
  });
  // For all popups - collecting the checked columns
  $(popup_elem + ' button.add_button').click(function() {
    $(popup_elem + ' input:checked').each(function(i, box) {
      add_column(source, $(this).siblings('input:hidden').val());
    });
    $(document).trigger('close.facebox');
  });

}

function search_table(source, q, page) {
  var popup_elem = 'div#' + source;
  var search_url = '/' + source + '/search?q=' + q + '&page=' + page;
  popup_spinner_on();
  $.ajax({
    success: function(data) {
      $(popup_elem + ' .search_table_inner').html(data);
      $(popup_elem + ' table.list tr.search_result td:not(td.' + source + '_box)').click(function() {    
        $(this).parent('tr').find('input:checkbox').click();
      });
      $(popup_elem + ' table.list tr.search_result td.' + source + '_box input').click(function() {
        $(this).parent('td').parent('tr').toggleClass('selected');
      });
      popup_spinner_off();
    },
    url: search_url
  });
  return false;
}

function add_column(source, column) {
  spinner_on();
  $.getJSON('/column.json', {source: source, column: column}, function(data) {
    var id = column_id(source, column);
    for (var bioguide_id in data) {
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
    
    var sort_class = data['type'] ? " {sorter: '" + data['type'] + "'}" : "";
    
    $('#main_table tr.titles').append(
      "<th class=\"" + id + sort_class + "\" title=\"" + escape_single_quotes(data['title']) + "\">" + 
      "<span>" + data['header'] + "</span>" + 
      "<a href=\"#\" title=\"Remove Column\" class=\"remove\"></a>" + 
      "<input type=\"hidden\" class=\"source\" value=\"" + source + "\" />" + 
      "<input type=\"hidden\" class=\"column\" value=\"" + column + "\" />" + 
      "</th>"
    );
    
    $('th.' + id + ' a.remove').click(function() {
      remove_column(source, column);
    });
    
    filter_links();
    
    spinner_off();
    prepare_table();
    
    current_columns[source + "[" + column + "]"] = 1;
    update_links();
    
    $('input#filter_field').focus();
  });
}

function remove_column(source, column) {
  spinner_on();
  $('.' + column_id(source, column)).remove();
  spinner_off();
  
  delete current_columns[source + "[" + column + "]"];
  update_links();
}

function update_links() {
  $('div.download a, div.permalink a').each(function(i, a) {
    a.href = table_url(a.id);
  });
}

function filter_links() {
  $('a.filter').click(function() {
    var filter = $('input#filter_field');
    filter.focus();
    filter.val(unencode($(this).html()));
    filter.keyup();
  });
}

function table_url(format) {
  if (format) 
    format = "." + format;
  else
    format = "";
    
  var query_string = query_string_for(current_columns);
  var url = "/table" + format + "?";
  if (current_filter)
    url += "filter=" + current_filter + "&";
  return url + query_string;
}

function query_string_for(options) {
  var string = [];
  for (var key in options)
    string.push(key + "=" + options[key]);
  return string.join("&");
}

function spinner_on() {$('#spinner').show();}
function spinner_off() {$('#spinner').hide();}

function popup_spinner_on() {$('.popup_spinner').show();}
function popup_spinner_off() {$('.popup_spinner').hide();}

function column_id(source, column) {
  return source + '_' + column.replace(/[^\w\d]/g, '_');
}

function escape_single_quotes(string) {
  return string.replace(/\'/g, '\\\'');
}

function unencode(string) {
  return string.replace('&amp;', '&');
}

function strip_search(string) {
  return string.replace(/[\"]/g, '');
}

/** Functions that deal with the raw table plugins **/

function prepare_table() {
  // clear onclick events on table headers, so they don't layer on each other
  $('#main_table th').unbind();
  
  $('#main_table').tablesorter({
    widgets: ['zebra']
  });
}

function filter_table(q, column) {
  // uiTableFilter expects the column argument to be a class name on the TH tag of that column
  $.uiTableFilter($('#main_table'), q, column);
}