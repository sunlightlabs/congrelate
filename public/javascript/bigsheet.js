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
  
  $("a#addVotes").facebox()
  $(document).bind('reveal.facebox', function() {
    $("div#facebox table").show();
    $("div#facebox div.content a#bustedLink").click(function() {
      $(document).trigger('close.facebox');

      //This is whatever you want the button/link/whatever to do.  Submit a form, pull back data, adjust the DOM, etc.
      $("table").hide("slow");
    });
  });
});
