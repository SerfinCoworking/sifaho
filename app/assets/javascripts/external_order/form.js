$(document).on('turbolinks:load', function(e){
  if(!(['establishments/external_orders/applicants','establishments/external_orders/providers', 'internal_orders'].includes(_PAGE.controller) && (['new', 'edit', 'accept_order', 'create', 'update'].includes(_PAGE.action))) ) return false;
  $('#effector-establishment').autocomplete({
    source: $('#effector-establishment').data('autocomplete-source'),
    minLength: 2,
    messages: {
      noResults: function(count) {
        $(".ui-menu-item-wrapper").html("No se encontró el establecimiento");
      }
    },
    select:
    function (event, ui) {
      // cargamos los sectores a seleccionar segun el establecimiento
      getSectorsByEstablishment(ui.item.id);
    }
  });
  
  function getSectorsByEstablishment(establishmentId){

    const select = $("#effector-sector");
    select.prop("disabled", false);
    $.ajax({
      url: "/sectores/with_establishment_id", // Ruta del controlador
      type: 'GET',
      data: {
        term: establishmentId
      },
      dataType: "json",
      error: function(XMLHttpRequest, errorTextStatus, error){
        alert("Failed: No se encontraron sectores"+ errorTextStatus+" ;"+error);
      },
      success: function(data){
        if (!data.length) {
          select.selectpicker({title: 'No hay sectores'}).selectpicker('render');
          $("#applicant-id").val('');
          html = '';
          select.html(html);
          select.selectpicker("refresh");
        }else{
          select.selectpicker({title: 'Seleccione un sector'}).selectpicker('render');
          select.empty().selectpicker('refresh'); // Se vacía el select
          // Se itera el json
          for(let i in data)
          {
            select.append('<option value="'+data[i].id+'">'+data[i].label+'</option>');
          }
          select.selectpicker('refresh');
        }
      } 
    });
  }
});