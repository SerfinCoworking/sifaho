$(document).on('turbolinks:load', function(e){
  if(!([
    'establishments/external_orders/templates/applicants', 
    'establishments/external_orders/templates/providers', 
    'sectors/internal_orders/templates/applicants', 
    'sectors/internal_orders/templates/providers'].includes(_PAGE.controller) && (['new', 'edit', 'create', 'update'].includes(_PAGE.action))) ) return false;
  // Función para autocompletar y buscar el insumo por código
  initEvents();
  
  $('#provider-establishment').autocomplete({
    source: $('#provider-establishment').data('autocomplete-source'),
    minLength: 2,
    messages: {
      noResults: function(count) {
        $(".ui-menu-item-wrapper").html("No se encontró el establecimiento");
      }
    },
    select:
    function (event, ui) {
      // cargamos los sectores a seleccionar segun el establecimiento
      $("input#provider-establishment-id").val(ui.item.id);
      getSectorsByEstablishment(ui.item.id);
    }
  });

  function getSectorsByEstablishment(establishmentId){

    const select = $("#provider-sector");
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

  // cocoon init
  $('#external_order_product_templates, #internal_order_product_templates').on('cocoon:after-insert', function(e, inserted_item) {
    initEvents();
    $(inserted_item).find('input.product-code').first().focus();
  });

  // set expiry date calendar format
  function initEvents(){
    // autocomplete establishment input
    $('.product-code').autocomplete({
      source: $('.product-code').attr('data-autocomplete-source'),
      minLength: 1,
      autoFocus: true,
      messages: {
        noResults: function(count) {
          $(".ui-menu-item-wrapper").html("No se encontró el código de insumo");
        }
      },
      search: function( event, ui ) {
        $(event.target).parent().siblings('.with-loading').first().addClass('visible');
      },
      select: function (event, ui) { 
        onChangeOnSelectAutoCProductCode(event.target, ui.item);
      },
      response: function(event, ui) {
        $(event.target).parent().siblings('.with-loading').first().removeClass('visible');
      }
    });

    // Función para autocompletar y buscar el insumo
    $('.product-name').autocomplete({
      source: $('.product-name').attr('data-autocomplete-source'),
      minLength: 1,
      autoFocus: true,
      messages: {
        noResults: function(count) {
          $(".ui-menu-item-wrapper").html("No se encontró el noombre del insumo");
        }
      },
      search: function( event, ui ) {
        $(event.target).parent().siblings('.with-loading').first().addClass('visible');
      },
      select: function (event, ui) { 
        onSelectAutoCSupplyName(event.target, ui.item);
        const tr = $(event.target).closest(".nested-fields");
        tr.find("input.request-quantity").focus(); // changes focus to quantity input
      },
      response: function(event, ui) {
        $(event.target).parent().siblings('.with-loading').first().removeClass('visible');
      }
    });
    
  }// initEvents function

  function onChangeOnSelectAutoCProductCode(target, item){
    if(item){
      const tr = $(target).closest(".nested-fields");
      tr.find("input.product-name").val(item.name); // update product name input
      tr.find("input.product-unity").val(item.unity); // update product unity input 
      tr.find("input.product-id").val(item.id); // update product id input  
     
    }
  }

  function onSelectAutoCSupplyName(target, item){
    if(item){
      const tr = $(target).closest(".nested-fields");
      tr.find("input.product-code").val(item.code); // update product name input
      tr.find("input.product-unity").val(item.unity); // update product unity input
      tr.find("input.product-id").val(item.id); // update product id input
    }
  }
});