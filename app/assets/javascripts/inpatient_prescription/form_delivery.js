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
  $('tbody.inpatient-order-product-cocoon-container').on('cocoon:after-insert', function(e, inserted_item) {
    
    $("input.product-quantity").on("change", function(e){
      const quantity = $(e.target).val();
      const pdtd = $(e.target).attr('data-product-dose-to-delivery');
      const total = quantity * pdtd;
      $(e.target).closest('tr').find('input.product-dose-total').first().val(total);
    });
  });
    
  // set expiry date calendar format
  function initEvents(){
    const trs = $('tbody.inpatient-order-product-cocoon-container').find('tr.nested-fields');
    trs.map((index, tr) => {

      const quantity = $(tr).find("input.product-quantity").attr('data-product-total-selected-quantity');
      const toDelivery = $(tr).find("input.product-dose-total").first().val();

      setLotSelectionProgress(tr, quantity, toDelivery);
    });
  }// initEvents function

  $('#dialog').on('hidden.bs.modal', function () {
    $('#dialog .modal-header').removeClass('bg-warning');
  });
});

// Se renderiza el porcentual del background
function setLotSelectionProgress(targetRow, selectedQuantity, toDelivery){
  if($(targetRow).find("input.stock-quantity").val() == 0){
    $(targetRow).find('button.btn-select-lot-stock').siblings().first().css({'width': '0%'});
    $(targetRow).find('button.btn-select-lot-stock').first().html('Sin stock');
    $(targetRow).find('button.btn-select-lot-stock').first().attr('disabled', true);
  }else{
    $(targetRow).find('button.btn-select-lot-stock').first().removeAttr('disabled');
    const quantityPercent = (selectedQuantity == 0 || toDelivery == 0) ? 0 : (selectedQuantity * 100 / toDelivery); //calc width percentage progress
    if(isNaN(quantityPercent)) return false; //return false if quantityPercent is NaN

    $(targetRow).find('button.btn-select-lot-stock').siblings().first().css({'width': (quantityPercent + '%')});
    
    if(quantityPercent === 100){
      // add success class
      $(targetRow).find('button.btn-select-lot-stock').siblings().first().addClass('complete-progress');
      $(targetRow).find('button.btn-select-lot-stock').first().addClass('complete-progress');

      // remove danger class
      $(targetRow).find('button.btn-select-lot-stock').siblings().first().removeClass('fail-progress');
      $(targetRow).find('button.btn-select-lot-stock').first().removeClass('fail-progress');
    }else if(quantityPercent < 100 ){
      // remove success class
      $(targetRow).find('button.btn-select-lot-stock').siblings().first().removeClass('complete-progress');
      $(targetRow).find('button.btn-select-lot-stock').first().removeClass('complete-progress');

      // remove danger class
      $(targetRow).find('button.btn-select-lot-stock').siblings().first().removeClass('fail-progress');
      $(targetRow).find('button.btn-select-lot-stock').first().removeClass('fail-progress');
    }else {
      // remove success class
      $(targetRow).find('button.btn-select-lot-stock').siblings().first().removeClass('complete-progress');
      $(targetRow).find('button.btn-select-lot-stock').first().removeClass('complete-progress');
      
      // add danger class
      $(targetRow).find('button.btn-select-lot-stock').siblings().first().addClass('fail-progress');
      $(targetRow).find('button.btn-select-lot-stock').first().addClass('fail-progress');
    }
  }
} 