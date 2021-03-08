$(document).on('turbolinks:load', function(e){
  if(!(['external_orders', 'internal_orders'].includes(_PAGE.controller) && (['new_applicant', 'edit_applicant','new_provider', 'edit_provider', 'accept_provider', 'create_applicant', 'update_applicant', 'create_provider', 'update_provider', 'send_provider'].includes(_PAGE.action))) ) return false;

  initEvents();
  
  // button submit
  $("button[type='submit']").on('click', function(e){
    e.preventDefault();
    $(e.target).attr('disabled', true);
    $(e.target).siblings('button, a').attr('disabled', true);
    $(e.target).find("div.c-msg").css({"display": "none"});
    $(e.target).find('div.d-none').toggleClass('d-none');
    $('input[name="commit"][type="hidden"]').val($(e.target).attr('data-value')).trigger('change');
    $('form#'+$(e.target).attr('form')).submit();
  });

  // cocoon init
  $('#order-product-cocoon-container').on('cocoon:after-insert', function(e) {
    initEvents();
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
    
    deliveryQuantityEventBinding();

    lotsQuantitySelection();
    
    const trs = $('#order-product-cocoon-container').find('tr.nested-fields');
    trs.map((index, tr) => {
      const toDelivery = $(tr).find("input.deliver-quantity").val(); // get delivery quanitty
      let totalQuantitySelected = 0;
      const lotStockHidden = $(tr).find('.lots').has('input._destroy[value="false"]');// filter values with _destroy=true
      let selectedQuantity;
      if(lotStockHidden.length){
        selectedQuantity = $(lotStockHidden).find('.lot_stock_quantity_ref');
        selectedQuantity.map((index, option) => {
          // option
          totalQuantitySelected += ($(option).val() * 1);
        });
      }
      setProgress(tr, totalQuantitySelected, toDelivery, (typeof(selectedQuantity) !== 'undefined' ? selectedQuantity.length : 0));
    });

  }// initEvents function

  function onChangeOnSelectAutoCProductCode(target, item){
    if(item){
      const tr = $(target).closest(".nested-fields");
      tr.find("input.product-name").val(item.name); // update product name input
      tr.find("input.product-unity").val(item.unity); // update product unity input      
      tr.find("input.stock-quantity").val(item.stock); // update product stock input
      tr.find("input.product-id").val(item.id); // update product id input  
      tr.find("input.request-quantity").focus();
      tr.find('div.lot-stocks-hidden').html('');
      setProgress(tr, 0, tr.find("input.deliver-quantity").first().val(), 0);
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
      setProgress(tr, 0, tr.find("input.deliver-quantity").first().val(), 0);
    }
  }

  function lotsQuantitySelection(){
    // Select del lote
    $(".select-lot-btn").on('click', function(e){
      const templateHidden = $(e.target).attr("data-template-fill-hidden");
      const tr = $(e.target).closest(".nested-fields");
      const rows = $('#order-product-cocoon-container').find('tr.nested-fields');
      
      const trIndex = $(rows).index(tr); // get the row index for manipulate lot hiddens fields value
      const url = $(e.target).attr('data-select-lot-url');
      const productCode = tr.find("input.product-code").val(); // get product code
      const toDelivery = tr.find("input.deliver-quantity").val(); // get delivery quanitty
      const hiddenTarget = tr.find(".lot-stocks-hidden").first();
      const selectedLots = $(hiddenTarget).find('.lots').has('input._destroy[value="false"]');
      
      if(!productCode){
        $('#dialog .modal-header').addClass('bg-warning');
        $('#dialog .modal-title').html("<i class='fa fa-exclamation-triangle'></i>  Elegir un producto");
        $('#dialog .modal-body').html("<p>No se ha seleccionado ningún producto</p><p>Por favor seleccione uno</p>");
        $('#dialog .modal-footer').html(
          "<button type='button' class='btn' data-dismiss='modal'>Volver</button>"
        );
        $('#dialog').modal("show");
        return;
      }
      $.ajax({
        url: url,
        method: 'GET',
        dataType: "JSON",
        data: {
          product_code: productCode
      }}).done(function(response){
        const table_body = drawLotTable(response, selectedLots, toDelivery);
        $('#lot-selection').find('.modal-body tbody').first().remove();
        $('#lot-selection table').append(table_body);
        $('#lot-selection').attr('data-template-hidden', templateHidden);
        $('#lot-selection').attr('data-hidden-target', hiddenTarget);
        $('#lot-selection').attr('data-index-row', trIndex);
        $('#lot-selection').attr('data-to-delivery', toDelivery);
        getCurrentSelectedQuantity();
        // Show the dynamic dialog
        $('#lot-selection').modal("show");

      });// End 

    });// End lot selection button click action
  }

  // On change delivery quantity
  function deliveryQuantityEventBinding(){
    $('input.deliver-quantity').on('change', function(e){
      const tr = $(e.target).closest(".nested-fields");
      const toDelivery = tr.find("input.deliver-quantity").val();
      
      $(tr).find('button.select-lot-btn').siblings().first().css({'width': (!($(e.target).val() > 0) ? '100%' : '0%')});

      totalQuantitySelected = 0;
      const selectedQuantity = $(tr).find('.lot-stocks-hidden .lot_stock_quantity_ref');
      selectedQuantity.map((index, option) => {
        // option
        totalQuantitySelected += ($(option).val() * 1);
      });

      setProgress(tr, totalQuantitySelected, toDelivery, selectedQuantity.length)
    });
  }

  
  // set progress bg, with quantity selected
  function setProgress(targetRow, totalQuantitySelected, toDelivery, selectedOptionsCount){
    const quantityPercent = totalQuantitySelected * 100 / toDelivery; //calc width percentage progress
    
    if(isNaN(quantityPercent)) return false; //return false if quantityPercent is NaN


    $(targetRow).find('button.select-lot-btn').siblings().first().css({'width': (quantityPercent + '%')});
    $(targetRow).find('button.select-lot-btn').first().html("Seleccionados " + selectedOptionsCount);
    
    if(quantityPercent === 100){
      // add success class
      $(targetRow).find('button.select-lot-btn').siblings().first().addClass('complete-progress');
      $(targetRow).find('button.select-lot-btn').first().addClass('complete-progress');

      // remove danger class
      $(targetRow).find('button.select-lot-btn').siblings().first().removeClass('fail-progress');
      $(targetRow).find('button.select-lot-btn').first().removeClass('fail-progress');
    }else if(quantityPercent < 100 ){
      // remove success class
      $(targetRow).find('button.select-lot-btn').siblings().first().removeClass('complete-progress');
      $(targetRow).find('button.select-lot-btn').first().removeClass('complete-progress');

      // remove danger class
      $(targetRow).find('button.select-lot-btn').siblings().first().removeClass('fail-progress');
      $(targetRow).find('button.select-lot-btn').first().removeClass('fail-progress');
    }else {
      // remove success class
      $(targetRow).find('button.select-lot-btn').siblings().first().removeClass('complete-progress');
      $(targetRow).find('button.select-lot-btn').first().removeClass('complete-progress');
      
      // add danger class
      $(targetRow).find('button.select-lot-btn').siblings().first().addClass('fail-progress');
      $(targetRow).find('button.select-lot-btn').first().addClass('fail-progress');
    }
  }

  // Remove style
  $('#lot-selection').on('hidden.bs.modal', function (e) {
    const templateHidden = $(e.target).attr('data-template-hidden');
    const trIndex = $(e.target).attr('data-index-row');
    const tr = $("#order-product-cocoon-container").find(".nested-fields")[trIndex];
    const toDelivery = $(e.target).attr('data-to-delivery');
    const hiddenTarget = $(tr).find(".lot-stocks-hidden").first();
    // handle selected options
    const selectedOptions = $(e.target).find('tbody tr.selected-row');
    const nonSelectedOptions = $(e.target).find('tbody tr').not('.selected-row');
    
    let totalQuantitySelected = 0;
    // update hidden lots values
    selectedOptions.map((index, option) => {
      const lot_stock_id = $(option).find('input[type="checkbox"]').first().val();
      const quantity = $(option).find('input[type="number"]').first().val() * 1;
      const lot = $(hiddenTarget).find('div.lots[data-lsid="'+ lot_stock_id +'"]').first();

      // if not exists
      if(lot.length){
        $(lot).find('input[type="hidden"].lot_stock_quantity_ref').first().val(quantity);
        $(lot).find('input[type="hidden"]._destroy').first().val(false);
      }else{
        addLot(hiddenTarget, templateHidden, lot_stock_id, quantity);
      }
      // totalize the quanitty
      totalQuantitySelected += quantity;
    });
    
    // remove hidden lots values
    nonSelectedOptions.map((index, option) => {
      const lot_stock_id = $(option).find('input[type="checkbox"]').first().val();
      const lot = $(hiddenTarget).find('div.lots[data-lsid="'+ lot_stock_id +'"]').first();

      // if exists set _destroy in TRUE
      if(lot.length){
        $(lot).find('input[type="hidden"]._destroy').first().val(true);
      }
    });

    setProgress(tr, totalQuantitySelected, toDelivery, selectedOptions.length);
    $(tr).find("input.deliver-quantity").first().val(totalQuantitySelected).trigger("change");
  }); 

  $('#dialog').on('hidden.bs.modal', function () {
    $('#dialog .modal-header').removeClass('bg-warning');
  });
});