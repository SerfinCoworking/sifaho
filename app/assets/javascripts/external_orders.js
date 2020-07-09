$("#establishment").on("click", function () {
    $(this).select();
});

// Función para autocompletar nombre de establecimiento
jQuery(function() {
  return $('#establishment').autocomplete({
    source: $('#establishment').data('autocomplete-source'),
    minLength: 2,
    messages: {
      noResults: function(count) {
        $(".ui-menu-item-wrapper").html("No se encontró el establecimiento");
      }
    },
    select:
    function (event, ui) {
      $("#establishment-id").val(ui.item.id);
      $('#establishment').trigger('change');
      $("#applicant-sector").prop('required',true);
    }
  })
});

// Se completa el select con los sectores asociados al establecimiento
$(document).on('change', '#establishment', function() {
  var select = $("#applicant-sector");
  select.prop("disabled", false);
  $.ajax({
    url: "/sectors/with_establishment_id", // Ruta del controlador
    type: 'GET',
    data: {
      term: $('#establishment-id').val()
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
      html = '';
        select.empty().selectpicker('refresh'); // Se vacía el select
        // Se itera el json
        for(var i in data)
        {
          select.append('<option value="'+data[i].id+'">'+data[i].label+'</option>');
        }
        select.selectpicker('refresh');
      }
    }
  });
});

// Evento del select sector para rellenar hidden id
$(document).on('change', '#applicant-sector', function() {
  $("#applicant-id").val($(this).val());
});//End on change events

// Completar cantidad de stock
$(document).on('change', '.select-change', function() {
  var nested_form = $(this).parents(".nested-fields");
  $.ajax({
    url: "/sector_supply_lots/get_stock_quantity", // Ruta del controlador
    type: 'GET',
    data: {
      term: nested_form.find('.supply-code').val()
    },
    dataType: "json",
    error: function(XMLHttpRequest, errorTextStatus, error){
      alert("Failed: "+ errorTextStatus+" ;"+error);
    },
    success: function(data){
      nested_form.find('.stock-quantity').val(data);
    }// End success
  });// End ajax
});// End jquery function completar cantidad en stock