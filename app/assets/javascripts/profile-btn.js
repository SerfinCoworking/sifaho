$(document).on('turbolinks:load', function() {

  $('input[name="theme"]').on('change', function(e){
    const isLight = $(e.target).prop('checked');
    const url = $(e.target).attr('data-url');
    let value = '';
    if(isLight){
      $("#wrapper").removeClass("light").addClass('dark');
      value = 'dark';
    }else{
      $("#wrapper").removeClass("dark").addClass("light");
      value = 'light';
    }
    updateTheme(url, value);
  });


  function updateTheme(url, theme){
    $.ajax({
      url: url,
      method: 'PATCH',
      data: { 
        profile: { theme } 
      }
    });
  }
});