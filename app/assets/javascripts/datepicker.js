$('#since_date').datepicker({
  format: 'DD/MM/YYYY',
  locale: 'es'
});


$(document).on("focus", "[data-behaviour~='datepicker']", function(e){
    $(this).datepicker({"format": "yyyy-mm-dd", "weekStart": 1, "autoclose": true})
});