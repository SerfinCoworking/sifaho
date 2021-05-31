$(document).on('turbolinks:load', function(e){

  if(!(['inpatient_prescriptions'].includes(_PAGE.controller) && (['delivery'].includes(_PAGE.action))) ) return false;
  initEvents();
  
  $('.inpatient-order-product-cocoon-container').on('cocoon:after-insert', function(e, inserted_item) {
    initEvents();

    // Guarda la fila del producto seleccionado
    // Valida que tenga almenos un producto seleccionado
    // y que tenga una cantidad por dosis
    $('button.btn-ipp-save').on('click', function(e){
      updateOrderProduct(e.target);
     /*  const tr = $(e.target).closest('tr');
      const url = $(tr).attr('data-url');
      const urlType = $(tr).attr('data-url-type');
      const parentId = $(tr).attr('data-parent-id');
      const productId = $(tr).find('input[type="hidden"].product-id').first().val();
      // const productQuantity = $(tr).find('input.product-quantity').first().val();
      const productDoseTotal = $(tr).find('input.product-dose-total').first().val();
      const productObservation = $(tr).find('textarea.product-observartion').first().val();
      $(tr).attr('id', "child-"+productId);
      if(typeof productId !== 'undefined' && typeof productDoseTotal !== 'undefined'){

        $.ajax({
          url: url,
          method: urlType,
          dataType: "script",
          data: {
            inpatient_prescription_product: {
              parent_id: parentId,
              product_id: productId,
              // quantity: productQuantity,
              dose_total: productDoseTotal,
              observation: productObservation
            }
          }
        });
      } */
    });
  });

  function initEvents(){
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

    /* habilitar edicion */
    $(".btn-ipp-edit").on('click', function(e){
      $(".order-product-inputs").removeAttr("readonly");
      $(".edit-btn-combo").fadeIn();
      $(".saved-btn-combo").fadeOut();
    });
    
    /* Cancelar edicion */
    $(".cancel-item").on('click', function(e){
      $(".order-product-inputs").attr("readonly", true);
      $(".edit-btn-combo").fadeOut();
      $(".saved-btn-combo").fadeIn();
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

  }// fin initEvents


  $("button[type='submit']").on('click', function(e){
    e.preventDefault();
    $(e.target).attr('disabled', true);
    // $(e.target).siblings('button, a').attr('disabled', true);
    $(e.target).find("div.c-msg").css({"display": "none"});
    $(e.target).find('div.d-none').toggleClass('d-none');
    $('input[name="commit"][type="hidden"]').val($(e.target).attr('data-value')).trigger('change');
    $('form#'+$(e.target).attr('form')).submit();
  });

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

  function updateOrderProduct(target){
    const url = $(target).attr('data-url');
    const urlType = $(target).attr('data-url-type');
    const parentId = $(target).attr('data-parent-id');
    const tr = $(target).closest('tr');
    const productId = $(tr).find('input[type="hidden"].product-id').first().val();
    const productDoseTotal = $(tr).find('input.product-dose-total').first().val();
    const productObservation = $(tr).find('textarea.product-observartion').first().val();
    $(tr).attr('id', "child-"+productId);
    if(typeof productId !== 'undefined' && typeof productDoseTotal !== 'undefined'){
      console.log(productId, productDoseTotal, "===================0debug");

      $.ajax({
        url: url,
        method: urlType,
        dataType: "script",
        data: {
          inpatient_prescription_product: {
            parent_id: parentId,
            product_id: productId,
            dose_total: productDoseTotal,
            observation: productObservation
          }
        }
      });
    }
  }

});