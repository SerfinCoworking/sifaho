$(document).on('turbolinks:load', function(e){

  if(!(['patient_product_state_reports', 'patient_product_reports'].includes(_PAGE.controller) && 
  (['new'].includes(_PAGE.action))) ) return false;

  initEvents();

  // cocoon init
  $('#report-product-cocoon-container').on('cocoon:after-insert', function(e, inserted_item) {
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

    // Función para autocompletar y buscar el producto
    $('.product-name').autocomplete({
      source: $('.product-name').attr('data-autocomplete-source'),
      minLength: 1,
      autoFocus: true,
      messages: {
        noResults: function(count) {
          $(".ui-menu-item-wrapper").html("No se encontró el noombre del producto");
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