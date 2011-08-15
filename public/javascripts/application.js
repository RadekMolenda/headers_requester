$(document).ready(function(){
  $("#remote").submit(function(event){
    $.ajax({
      type: 'POST',
      url: '/search',
      data: 'search_urls=' + $("input#search_urls").val()
    });
    return false;
  });
  client = new Faye.Client('/faye');

  var template_ok = null;
  var template_err = null;

  $.get('/public/javascripts/mustache/ok.mustache', function(data){
    template_ok = data
  });
  $.get('/public/javascripts/mustache/err.mustache', function(data){
    template_err = data
  });
  client.subscribe('/sites/success', function(data){
    $("#responses").append(Mustache.to_html(template_ok, data));
  });
  client.subscribe('/sites/failure', function(data){
    $("#responses").append(Mustache.to_html(template_err, data));
  });
});
