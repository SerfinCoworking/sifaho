$(document).on('turbolinks:load', function(e){

  if(!(['inpatient_prescriptions'].includes(_PAGE.controller) && (['delivery'].includes(_PAGE.action))) ) return false;
  
  initEvents();
  
  // button submit
  // $("button[type='submit']").on('click', function(e){
  //   e.preventDefault();
  //   $(e.target).attr('disabled', true);
  //   $(e.target).siblings('button, a').attr('disabled', true);
  //   $(e.target).find("div.c-msg").css({"display": "none"});
  //   $(e.target).find('div.d-none').toggleClass('d-none');
  //   $('input[name="commit"][type="hidden"]').val($(e.target).attr('data-value')).trigger('change');
  //   $('form#'+$(e.target).attr('form')).submit();
  // });

  // cocoon init
  /* $('#inpatient-order-product-cocoon-container').on('cocoon:after-insert', function(e, inserted_item) {
    initEvents();
  }); */
    
  // set expiry date calendar format
  function initEvents(){
   
    const trs = $('#inpatient-order-product-cocoon-container').find('tr.nested-fields');
    trs.map((index, tr) => {
      const toDose = $(tr).find("input.total-dose").first().val(); // get total dose
      const toDelivery = $(tr).find("input.to-delivery").first().val(); // get delivery quanitty
      setLotSelectionProgress(tr, toDose, toDelivery);
    });

  }// initEvents function

  // set progress bg, with quantity selected
  

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

    $(tr).find("input.to-delivery").first().val(totalQuantitySelected).trigger("change");
    setLotSelectionProgress(tr, totalQuantitySelected, toDelivery, selectedOptions.length);
  });

  $('#dialog').on('hidden.bs.modal', function () {
    $('#dialog .modal-header').removeClass('bg-warning');
  });
});

// Se renderiza el porcentual del background
function setLotSelectionProgress(targetRow, totalDose, toDelivery){
  if($(targetRow).find("input.stock-quantity").val() == 0){
    $(targetRow).find('button.select-lot-btn').siblings().first().css({'width': '0%'});
    $(targetRow).find('button.select-lot-btn').first().html('Sin stock');
    $(targetRow).find('button.select-lot-btn').first().attr('disabled', true);
  }else{
    $(targetRow).find('button.select-lot-btn').first().removeAttr('disabled');
    const quantityPercent = (totalDose == 0 || toDelivery == 0) ? 0 : (toDelivery * 100 / totalDose); //calc width percentage progress
    if(isNaN(quantityPercent)) return false; //return false if quantityPercent is NaN


    $(targetRow).find('button.select-lot-btn').siblings().first().css({'width': (quantityPercent + '%')});
    
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