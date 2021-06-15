$(document).on('turbolinks:load', function(e){

  if(!(['inpatient_prescriptions'].includes(_PAGE.controller) && (['delivery', 'set_products'].includes(_PAGE.action))) ) return false;
  
  initEvents();
  
  $('.inpatient-order-product-cocoon-container').on('cocoon:after-insert', function(e, inserted_item) {
    initEvents();

    // Guarda la fila del producto seleccionado
    // Valida que tenga almenos un producto seleccionado
    // y que tenga una cantidad por dosis
  });
  
  function initEvents(){
    $('button.btn-ipp-save').on('click', function(e){
      updateOrderProduct(e.target);
    });
    $('button.btn-select-lot-stock').on('click', function(e) {
      e.stopPropagation();
      const urlFindLots = $(e.target).attr("data-select-lot-url");
      const orderName = $(e.target).attr("data-order-name");
      const orderId = $(e.target).attr("data-order-id");
      const orderProductId = $(e.target).attr("data-order-product-id");
      const productId = $(e.target).closest('tr').find('input[type="hidden"].product-id').first().val();
      $.ajax({
        url: urlFindLots,
        method: 'GET',
        dataType: "script",
        data: {
          order_type: orderName,
          order_id: orderId,
          order_product_id: orderProductId,
          product_id: productId
      }});
    });

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

    // /* habilitar edicion */
    // $(".btn-ipp-edit").on('click', function(e){
    //   const tr = $(e.target).closest('tr');
    //   $(tr).find(".order-product-inputs").removeAttr("readonly");
    //   $(tr).find(".saved-btn-combo").fadeOut(500, function(){
    //     $(tr).find(".edit-btn-combo").fadeIn();
    //   });
    // });
    
    // /* Cancelar edicion */
    // $(".cancel-item").on('click', function(e){
    //   const tr = $(e.target).closest('tr');
    //   $(tr).find(".order-product-inputs").attr("readonly", true);
    //   $(tr).find(".edit-btn-combo").fadeOut(500, function(){
    //     $(tr).find(".saved-btn-combo").fadeIn();
    //   });
    //   const url = $(e.target).attr('data-url');
    //   const urlType = $(e.target).attr('data-url-type');
    //   $.ajax({
    //     url: url,
    //     method: urlType,
    //     dataType: "script",
    //   });
    // });
    
    // /* Guardar modificaciones */
    // $(".update-item").on('click', function(e){
    //   updateOrderProduct(e.target)
    // });
    initActionsButton();
    calcTotalDoseEvent();

  }// fin initEvents


  // $("button[type='submit']").on('click', function(e){
  //   e.preventDefault();
  //   $(e.target).attr('disabled', true);
  //   // $(e.target).siblings('button, a').attr('disabled', true);
  //   $(e.target).find("div.c-msg").css({"display": "none"});
  //   $(e.target).find('div.d-none').toggleClass('d-none');
  //   $('input[name="commit"][type="hidden"]').val($(e.target).attr('data-value')).trigger('change');
  //   $('form#'+$(e.target).attr('form')).submit();
  // });

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
  };
  
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
    $(row).find('input.product-dose-total').first().val(total);
  }

});

function updateOrderProduct(target){
  const url = $(target).attr('data-url');
  const urlType = $(target).attr('data-url-type');
  const tr = $(target).closest('tr');
  const parent_id = $(target).attr('data-parent-id');
  const product_id = $(tr).find('input[type="hidden"].product-id').first().val();
  const dose_quantity = $(tr).find('input.dose-quantity').first().val();
  const interval = $(tr).find('input.dose-interval').first().val();
  // const deliver_quantity = $(tr).find('input[type="hidden"].product-id').first().val();
  const total_dose = $(tr).find('input.product-dose-total').first().val();
  const observation = $(tr).find('textarea.product-observartion').first().val();
  const trId = parent_id ? "child-"+product_id : "parent-"+product_id;
  $(tr).attr('id', trId);

  if(typeof product_id !== 'undefined'){

    $.ajax({
      url: url,
      method: urlType,
      dataType: "script",
      data: {
        inpatient_prescription_product: {
          product_id: product_id,
          dose_quantity: dose_quantity,
          interval: interval,
          // deliver_quantity: deliver_quantity,
          observation: observation,
          parent_id: parent_id,
          total_dose: total_dose
        }
      }
    });
  }
}

function initActionsButton(){
  $('.delete-item').on('click', function(e) {
    const modal = $(e.target).attr('data-target');
    const title = $(e.target).attr('data-title');
    const body = $(e.target).attr('data-body');
    const href = $(e.target).attr('data-href');
  
    $(modal).find('.modal-title').text(title);
    $(modal).find('.modal-body').text(body);
    $(modal).find('.btn[data-method="delete"]').attr('href', href);
    $(modal).modal('toggle');
  });
  
  /* habilitar edicion */
  $(".btn-ipp-edit").on('click', function(e){
    const tr = $(e.target).closest('tr');
    $(tr).find(".order-product-inputs").removeAttr("readonly");
    $(tr).find(".saved-btn-combo").fadeOut(500, function(){
      $(tr).find(".edit-btn-combo").fadeIn();
    });
  });
  
  /* Cancelar edicion */
  $(".cancel-item").on('click', function(e){
    const tr = $(e.target).closest('tr');
    $(tr).find(".order-product-inputs").attr("readonly", true);
    $(tr).find(".edit-btn-combo").fadeOut(500, function(){
      $(tr).find(".saved-btn-combo").fadeIn();
    });
    const url = $(e.target).attr('data-url');
    const urlType = $(e.target).attr('data-url-type');
    $.ajax({
      url: url,
      method: urlType,
      dataType: "script",
    });
  });
  
  /* Guardar modificaciones */
  $(".update-item").on('click', function(e){
    updateOrderProduct(e.target)
  });
}