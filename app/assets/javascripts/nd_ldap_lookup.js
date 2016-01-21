/*!
* People Search
* @author Erik Runyon
* Updated 2014-05-12
*/
jQuery(function($){
  $('#people-results').on('click', '.person-details-show', function(){
    var $this = $(this);
    if($this.find('i').hasClass('icon-sort-down')){
      $this.html('Less&nbsp;<i class="icon-sort-up"></i>');
    } else {
      $this.html('More&nbsp;<i class="icon-sort-down"></i>');
    }
    $this.siblings('.person-details').slideToggle();
  });

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
        if(response.response == 'success'){
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
      if(item.affiliation_primary.length > 0) output += '<span class="person-primary-affiliation">('+ item.affiliation_primary +')</span> ';
      output += '<span class="person-details-show btn btn-mini">More&nbsp;<i class="icon-sort-down"></i></span><ul class="person-details">';
      output += itemList(item.title, 'person-title');
      output += itemList(item.dept, 'person-dept');
      output += itemList(item.telephone, 'person-phone');
      if(item.email) output += '<li class="person-email"><a href="mailto:' + item.email + '">' + item.email + '</a></li>';
      if(item.address_postal) {
        output += '<li class="person-address">' + item.address_postal + '</li>';
      } else if(item.address) {
        output += '<li class="person-address">' + item.address + '</li>';
      }
      output += '<li class="person-more"><a class="btn btn-mini" href="http://eds.nd.edu/cgi-bin/nd_ldap_search.pl?ldapfilter=uid='+ item.uid +'">Details&hellip;</a></li>';
      output += '</ul></li>';
    });
    output += '</ul>';
    if(data.length == 0) output = '<p>No results found.</p>';
    $results.html(output);
  }

  function itemList(item, listClass){
    var output = '';
    if(item && item.length > 0){
      output = '<li><ul class="'+ listClass +'">';
      $.each(item, function(){
        if(listClass == 'person-phone'){
          output += '<li><a class="tel" href="tel:1-'+ this +'">'+ this +'</a></li>';
        } else {
          output += '<li>'+ this +'</li>';
        }
      });
      output += '</ul></li>';
    }
    return output;
  }
});
