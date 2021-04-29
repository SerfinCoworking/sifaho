$(document).on('turbolinks:load', function(e){

  if(!(['inpatient_prescriptions'].includes(_PAGE.controller) && (['delivery'].includes(_PAGE.action))) ) return false;
  
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
  $('#inpatient-order-product-cocoon-container').on('cocoon:after-insert', function(e, inserted_item) {
    initEvents();
  });
  
  
  // set expiry date calendar format
  function initEvents(){

    lotsQuantitySelection();
    
    const trs = $('#inpatient-order-product-cocoon-container').find('tr.nested-fields');
    trs.map((index, tr) => {
      const toDelivery = $(tr).find("input.total-dose").first().val(); // get delivery quanitty
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

  function lotsQuantitySelection(){
    // Select del lote
    $(".select-lot-btn").on('click', function(e){
      const templateHidden = $(e.target).attr("data-template-fill-hidden");
      const tr = $(e.target).closest(".nested-fields");
      const rows = $('#inpatient-order-product-cocoon-container').find('tr.nested-fields');
      
      const trIndex = $(rows).index(tr); // get the row index for manipulate lot hiddens fields value
      const url = $(e.target).attr('data-select-lot-url');
      const productId = tr.find("input.product-id").val(); // get product code
      const toDelivery = tr.find("input.total-dose").val(); // get delivery quanitty
      const hiddenTarget = tr.find(".lot-stocks-hidden").first();
      const selectedLots = $(hiddenTarget).find('.lots').has('input._destroy[value="false"]');
      
      if(!productId){
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
          product_id: productId
      }}).done(function(response){
        const table_body = drawLotTable(response, selectedLots, toDelivery);
        $('#lot-selection').find('.modal-body tbody').first().remove();
        $('#lot-selection table').append(table_body);
        $('#lot-selection').attr('data-template-hidden', templateHidden);
        $('#lot-selection').attr('data-hidden-target', hiddenTarget);
        $('#lot-selection').attr('data-index-row', trIndex);
        $('#lot-selection').attr('data-to-delivery', toDelivery);

        $('#lot-selection table').find('input.lot-quantity').on('click', function(){
          this.select();
        });

        getCurrentSelectedQuantity();
        // Show the dynamic dialog
        $('#lot-selection').modal("show");

      });// End 

    });// End lot selection button click action
  }
  
  // set progress bg, with quantity selected
  function setProgress(targetRow, totalQuantitySelected, toDelivery, selectedOptionsCount){
    if($(targetRow).find("input.stock-quantity").val() == 0){
      $(targetRow).find('button.select-lot-btn').siblings().first().css({'width': '0%'});
      $(targetRow).find('button.select-lot-btn').first().html('Sin stock');
      $(targetRow).find('button.select-lot-btn').first().attr('disabled', true);
    }else{
      $(targetRow).find('button.select-lot-btn').first().removeAttr('disabled');
      const quantityPercent = (totalQuantitySelected == 0 || toDelivery == 0) ? 0 : (totalQuantitySelected * 100 / toDelivery); //calc width percentage progress
      console.log(quantityPercent, "<======================================================DEBUG");
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
  } 

  // Remove style
  $('#lot-selection').on('hidden.bs.modal', function (e) {
    const templateHidden = $(e.target).attr('data-template-hidden');
    const trIndex = $(e.target).attr('data-index-row');
    const tr = $("#inpatient-order-product-cocoon-container").find(".nested-fields")[trIndex];
    // const toDelivery = $(e.target).attr('data-to-delivery');
    const toDelivery = $(tr).find("input.total-dose").val(); // get delivery quanitty
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
  });

  $('#dialog').on('hidden.bs.modal', function () {
    $('#dialog .modal-header').removeClass('bg-warning');
  });
});