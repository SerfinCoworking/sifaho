$(document).on('turbolinks:load', function(e){

  if(!(['inpatient_prescriptions'].includes(_PAGE.controller) && (['set_productsasdsad'].includes(_PAGE.action))) ) return false;
  
  initEvents();
  
  // cocoon init
  $('#inpatient-order-product-cocoon-container').on('cocoon:after-insert', function(e, inserted_item) {
    initEvents();
    $(inserted_item).find('input.product-code').first().focus();
  });

  // set expiry date calendar format
  function initEvents(){
    
    // autocomplete codigo de producto
    $('.product-code').on('keydown', function(e){
      e.stopPropagation();
    
      $(e.target).autocomplete({
        source: $(e.target).attr('data-autocomplete-source'),
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
    });

    $('.product-name').on('keydown', function(e){
      // Función para autocompletar y buscar el insumo
      $(e.target).autocomplete({
        source: $(e.target).attr('data-autocomplete-source'),
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
          tr.find("input.dose-quantity").focus(); // changes focus to quantity input
        },
        response: function(event, ui) {
          $(event.target).parent().siblings('.with-loading').first().removeClass('visible');
        }
      });
    });
    
    calcTotalDoseEvent();

    $('button.btn-ipp-save').on('click', function(e){
      const url = $(e.target).attr('data-url');
      const tr = $(e.target).closest('tr');
      const product_id = $(tr).find('input.product-id[type="hidden"]').first().val();
      const dose_quantity = $(tr).find('input.dose-quantity').first().val();
      const interval = $(tr).find('input.dose-interval').first().val();
      const observation = $(tr).find('textarea.observation').first().val();
      $.ajax({
        url: url,
        method: 'POST',
        dataType: "script",
        data: {
          inpatient_prescription_product: {
            product_id: product_id,
            dose_quantity: dose_quantity,
            interval: interval,
            observation: observation
          }
      }});
    });
  }// initEvents function

  function onChangeOnSelectAutoCProductCode(target, item){
    if(item){
      const tr = $(target).closest(".nested-fields");
      tr.find("input.product-name").val(item.name); // update product name input
      tr.find("input.product-unity").val(item.unity); // update product unity input      
      tr.find("input.stock-quantity").val(item.stock); // update product stock input
      tr.find("input.product-id").val(item.id); // update product id input  
      tr.find("input.deliver-quantity").first().focus();
      tr.find('div.lot-stocks-hidden').html('');
    }
  }

  function onSelectAutoCSupplyName(target, item){
    if(item){
      const tr = $(target).closest(".nested-fields");
      tr.find("input.product-code").val(item.code); // update product name input
      tr.find("input.product-unity").val(item.unity); // update product unity input
      tr.find("input.stock-quantity").val(item.stock); // update product stock input
      tr.find("input.product-id").val(item.id); // update product id input
      tr.find('div.lot-stocks-hidden').html('');
    }
  }

  // On change delivery quantity
  function calcTotalDoseEvent(){
    /* Request Dose and Interval dose */
    $('input.dose-quantity , input.dose-interval').on('change', function(e){
      const tr = $(e.target).closest(".nested-fields");
      calcTotalDose(tr);
    });
  }

  function calcTotalDose(row){
    const totalRequestDose = $(row).find('input.dose-quantity').first().val() || 0;
    const totalIntervalDose = $(row).find('input.dose-interval').first().val() || 0;
    const total = (24 /  totalIntervalDose) * totalRequestDose;
    $(row).find('input.total-dose').first().val(total);
  }
});