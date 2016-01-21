/*!
* People Search
* @author Erik Runyon
* Updated 2014-05-12
*/
jQuery(function($){
  'use strict';

  $('#ldap').on('submit', function(e){
    e.preventDefault();
    var $button = $('#people-submit'),
        $icon = $button.find('i'),
        query = $(this).find('.people-q').val(),
        api = "//www3.nd.edu/~webdev/utilities/ldap/?callback=?",
        $results = $('#people-results'),
        error = '<p>Error!</p>'
    ;
    if(query.length >= 2){
      $button.prop('disabled', true);
      $icon.removeClass('icon-search').addClass('icon-arrows-cw animate-spin');
      $.getJSON( api, {
        q: query
      })
      .done(function(response) {
        $button.prop('disabled', false);
        $icon.removeClass('icon-arrows-cw animate-spin').addClass('icon-search');
        if(response.response === 'success'){
          showResults(response.data);
        } else {
          $results.html(error);
        }
      })
      .fail(function() {
        $results.html(error);
      })
      ;
    } else {
      $results.html('Error: A search must be at least two characters in length.');
    }
  });

  function showResults(data){
    var $results = $('#people-results'),
        output = '<ul>'
    ;
    $.each(data, function(){
      var item = this;
      var name = (item.formal_name) ? item.formal_name : item.fullname;
      output += '<li><b class="person-name">'+ name +'</b> ';
      if(item.affiliation_primary.length > 0){ output += '<span class="person-primary-affiliation">('+ item.affiliation_primary +')</span> '; }
      output += '<ul class="person-details">';
      output += itemList(item.title, 'person-title');
      output += itemList(item.dept, 'person-dept');
      if(item.email){ output += '<li class="person-email"><a href="mailto:' + item.email + '">' + item.email + '</a></li>'; }
      if(item.id){ output += '<li class="person-netid">NetID: ' + item.id + '</li>'; }
      output += '</ul></li>';
    });
    output += '</ul>';
    if(data.length === 0){ output = '<p>No results found.</p>'; }
    $results.html(output);
  }

  function itemList(item, listClass){
    var output = '';
    if(item && item.length > 0){
      output = '<li><ul class="'+ listClass +'">';
      $.each(item, function(){
        output += '<li>'+ this +'</li>';
      });
      output += '</ul></li>';
    }
    return output;
  }
});
