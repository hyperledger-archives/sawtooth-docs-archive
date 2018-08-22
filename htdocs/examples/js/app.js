$(function() {
  //Protect Email
  var e = "distributedledger";
  var a = "@";
  var d = "intel";
  var c = ".com";
  var b = "Inquiry%20From%20Sawtooth%20Website";
  var h = 'mailto:' + e + a + d + c + "?subject=" + b;
  $('.email').attr('href', h);
  $('noscript').hide();
  
  //Prevent coming soon/disabled links from jumping to top of page
  $('.disabled').click(function(e) {
    e.preventDefault();
  });
  $('.coming-soon a').click(function(e) {
    e.preventDefault();
  });
});
