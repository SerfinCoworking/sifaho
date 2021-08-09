$(document).on('turbolinks:load', function(e){
  if(!(['products'].includes(_PAGE.controller) && (['new', 'edit', 'create', 'update'].includes(_PAGE.action))) ) return false;

  // Función para autocompletar y buscar el insumo
  $('.product-snomed-concept').autocomplete({
    source: function(request, response) {
      $.ajax({
        url: $('.product-snomed-concept').attr('data-autocomplete-source'),
        dataType: "json",
        data: {
          by_term: request.term,
        },
        success: function(data) {
          response(data);
        }
      });
    },
    minLength: 1,
    autoFocus: true,
    messages: {
      noResults: function(count) {
        $(".ui-menu-item-wrapper").html("No se encontró el nombre del concepto");
      }
    },
    search: function( event, ui ) {
      $(event.target).parent().siblings('.with-loading').first().addClass('visible');
    },
    select: function (event, ui) {
      $('#product_snomed_concept_id').val(ui.item.id);
    },
    response: function(event, ui) {
      $(event.target).parent().siblings('.with-loading').first().removeClass('visible');
    }
  });
});