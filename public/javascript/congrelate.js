var mainTable;

var current_columns = {
  'legislator[name]': 1,
  'legislator[state]': 1,
  'legislator[district]':1,
};
var current_filter = "";
var attribution_links = "";
var intro_cleared = false;
var query_keys = get_query_keys();

function init() {

  prepare_table();
  
  // Populate current_columns from query string
  if (query_keys.length > 0) {
    current_columns = {};
    for(var i = 0; i < query_keys.length; i++) {
      if(query_keys[i] != 'filter') {
        current_columns[query_keys[i]] = 1;
      }
    }
  }
    
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
      
      if (filter == "") {
        $('div.filtering.help').hide();
      } else {
        $('div.filtering.help').show();
        $('div.filtering.help span').html(display_filter(filter));
      }
  
      clear_intro();
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
  
  // update attribution
  update_attributions();
  if (query_keys.length > 0)
    $('div.attribution.help').show();
  
  // table functions
  $('tr.titles th a.remove').click(function() {
    var source = $(this).siblings('input.source').val();
    var column = $(this).siblings('input.column').val();
    remove_column(source, column);
  });
  
  $(document).bind('reveal.facebox', function() {
    $('div#facebox table').show();
  });
  
  // Activate the clear button
  $('button#clear_button, div.filtering.help a').click(clear_filter);
  
  // Clearing the intro
  $('button.startedBtn').click(clear_intro);  
}

function clear_intro() {
  if (!intro_cleared) {
    $('div.intro').hide();
    $('table.display').show();
    $('div.attribution.help').show();
    intro_cleared = true;
    prepare_table();
    return false;
  }
}

function update_attributions() {
  $.getJSON('/sources.json', function(data) {
    var source_keywords = [];

    for (var key in current_columns) {
      source_keywords.push(keysplode(key)['source']);
    }

    $('div.attribution.help span').html('');
    attribution_links = [];
    $.each(data, function(sourceIndex, source) {      
     if (source_keywords.contains(source['keyword'])) {
       attribution_links.push("<a href='" + source['source_url'] + "'>" + source['source_name'] + "</a>");
     }
    });
    $('div.attribution.help span').html(attribution_links.join(' ,'));
  });
}

function clear_filter() {
  $('input#filter_field').val('');
  $('input#filter_field').addClass('activated');
  filter_table('');
  $('input#filter_field').focus();
  
  $('div.filtering.help').hide();
  current_filter = ""
  update_links();
}

function init_source_form(source) {
  // For popups with a search field - the search form
  var popup_elem = 'div#' + source;
  
  // Pre-check the current_columns
  for (var key in current_columns) {
    $(popup_elem + ' :checkbox[name=' + key + ']').attr('checked','1')
                                                  .parents('table.grid td').toggleClass('selected');
  }  
  // Events
  $(popup_elem + ' form.search_name_form').submit(function() {
    return search_table(source, $('#search_name_field_' + source).val(), 1);
  });
  $(popup_elem + ' div.search_field input.search').focus(function() {this.value = '';})
  
  // For popups with a grid of checkboxes
  $(popup_elem + ' table.grid td input:checkbox').click(function() {
    $(this).parents('table.grid td').toggleClass('selected');
  });
  // For all popups - collecting the checked columns
  $(popup_elem + ' button.add_button').click(function() {
    $(popup_elem + ' input:checked').each(function(i, box) {
      var column_value = $(this).siblings('input:hidden').val() 
      if (!current_columns.hasOwnProperty(source + '[' + column_value + ']' )) {
        add_column(source, column_value);        
      }
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
      for (var key in current_columns) {
        var keysplosion = keysplode(key);
        var hidden_field = $(popup_elem + ' :hidden[value=' + keysplosion['value'] + ']')
        hidden_field.siblings(':checkbox').attr('checked','1');
        hidden_field.parent('td').parent('tr').toggleClass('selected');
      }      
      popup_spinner_off();
    },
    url: search_url
  });
  return false;
}

// translate a key like foo[bar] into an object where source=foo and value=bar
function keysplode(key) {
  first_split = key.split("[");
  source = first_split[0];
  second_split = first_split[1].split("]");
  value = second_split[0];
  return { "source":source, "value":value };
}

// get the keys from the query string
function get_query_keys() {
  var query_keys = [];
  var query = window.location.search.substring(1);
  var parms = query.split('&');
  for (var i=0; i<parms.length; i++) {
    var pos = parms[i].indexOf('=');
    if (pos > 0) {
      var key = unescape(parms[i].substring(0,pos));
      var val = unescape(parms[i].substring(pos+1));
      query_keys[i] = key;
    }
  }
  return query_keys;
}


function add_column(source, column) {
  spinner_on();
  $.getJSON('/column.json', {source: source, column: column}, function(data) {
    if (data.title == null)
      data.title = '';
    window.all_data = data;
    var id = column_id(source, column);
    
    for (var bioguide_id in data) {
      var row = $('tr#' + bioguide_id);
      if (row) {
        var cell;
        
        if (typeof(data[bioguide_id]) == 'string' || typeof(data[bioguide_id]) == 'number')
          cell = data[bioguide_id]
        else if (data[bioguide_id] != null && typeof(data[bioguide_id]) == 'object')
          cell = data[bioguide_id].html;
        else
          cell = null;
        
        $('tr#' + bioguide_id).append('<td class="' + id + '">' + (cell || '') + '</tr>');
      }
      clear_intro();
    }
    
    var sort_class = data.type ? " {sorter: '" + data.type + "'}" : "";
    
    $('#main_table tr.titles').append(
      "<th class=\"" + id + sort_class + "\" title=\"" + escape_single_quotes(data.title) + "\">" + 
      "<span>" + data.header + "</span>" + 
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
    update_attributions();
    
    $('input#filter_field').focus();
  });
}

function remove_column(source, column) {
  spinner_on();
  $('.' + column_id(source, column)).remove();
  spinner_off();
  
  delete current_columns[source + "[" + column + "]"];
  update_links();
  update_attributions();
}

function sort_column() {
  $('.sorting.help').show();
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
    string.push(escape(key) + "=" + options[key]);
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

function display_filter(string) {
  return "\"" + string.split(/\s+/).join("\", \"") + "\"";
}

/** Functions that deal with the raw table plugins **/

function prepare_table() {
  // clear onclick events on table headers, so they don't layer on each other
  $('#main_table th').unbind();
  
  $('#main_table').tablesorter({
    widgets: ['zebra'],
    sortInitialOrder: 'desc'
  });
  
  $('#main_table th.header').click(sort_column);
}

function filter_table(q, column) {
  // uiTableFilter expects the column argument to be a class name on the TH tag of that column
  $.uiTableFilter($('#main_table'), q, column);
}

Array.prototype.unique = function() {
  var a = [];
  var l = this.length;
  for (var i = 0; i < l; i++) {
    for (var j = i + 1; j < l; j++) {
      if (this[i] === this[j])
        j = ++i;
    }
    a.push(this[i]);
  }
  return a;
};
  
Array.prototype.contains = function(obj) {
  var i = this.length;
  while (i--) {
    if (this[i] === obj) {
      return true;
    }
  }
  return false;
}
