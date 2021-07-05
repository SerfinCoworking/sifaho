$(document).on('turbolinks:load', function(e){
  if(!(_PAGE.controller === 'users' && (['edit_permissions'].includes(_PAGE.action))) ) return false;
  
   // Función para autocompletar nombre y apellido del doctor
   $('#professional').autocomplete({
    source: $('#professional').data('autocomplete-source'),
    minLength: 2,
    autoFocus:true,
    messages: {
      noResults: function(count) {
        $(".ui-menu-item-wrapper").html("No se encontró al médico");
      }
    },
    search: function( event, ui ) {
      $(event.target).parent().siblings('.with-loading').first().addClass('visible');
    },
    select:
    function (event, ui) {
      $("#professional_id").val(ui.item.id);
    },
    response: function(event, ui) {
      $(event.target).parent().siblings('.with-loading').first().removeClass('visible');
    }
  });

});