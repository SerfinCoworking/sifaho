$(document).on('turbolinks:load', function() {
  $('input[name="theme"]').on('change', function(e){
    const isLight = $(e.target).prop('checked');
    if(isLight){
      $("#wrapper").removeClass("light").addClass('dark');
    }else{
      $("#wrapper").removeClass("dark").addClass("light");
    }
    console.log($(e.target).prop('checked'), "<==========00");
    
  });
});