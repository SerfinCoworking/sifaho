$(document).on('turbolinks:load', function() {
  $(document).on('change', '#report-select', function(e){
    var showInput = $('option:selected', this).attr("data-show"); 
    console.log("cambió");
    console.log("Data attribute: "+showInput);
    jQuery(function() {
      if ( showInput == "establishment" ){
        console.log("Entró");
        $(document).find(".establishment").css('display', 'block');
      }else{
        $(document).find(".establishment").css('display', 'none');
      }
    });
  });
});