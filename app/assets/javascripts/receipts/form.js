$(document).on('turbolinks:load', function(e){
  
  if( _PAGE.controller !== 'receipts' && (_PAGE.action !== 'new' || _PAGE.action !== 'edit') ) return false;

  $('#receipt-provider-id').autocomplete({
    source: $('#receipt-provider-id').data('autocomplete-source'),
    minLength: 2,
    autoFocus:true,
    messages: {
      noResults: function() {
        $(".ui-menu-item-wrapper").html("No se encontró al médico");
      }
    },
    search: function( event, ui ) {
      $(event.target).parent().siblings('.with-loading').first().addClass('visible');
    },
    select:
    function (event, ui) {
      getSectors(ui.item.id);
    },
    response: function(event, ui) {
      $(event.target).parent().siblings('.with-loading').first().removeClass('visible');
    }
  });

  function getSectors(establishmentId){
    $.ajax({
      url: "/sectors/with_establishment_id", // Ruta del controlador
      method: "GET",
      dataType: "JSON",
      data: { term: establishmentId}
    })
    .done(function( data ) {
      if(data.length){
        $('#provider-sector').removeAttr("disabled");
        $('#provider-sector').find('option').remove();
        $.each(data, function(index, element){
          $('#provider-sector').append('<option value="'+element.id+'">'+ element.label +'</option>');
        });
        $('#provider-sector').selectpicker('refresh', {style: 'btn-sm btn-default'});
      }else{
        console.log("no se encontraron sectores");
      }
    });
  }
});