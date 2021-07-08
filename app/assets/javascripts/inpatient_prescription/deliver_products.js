$(document).on('turbolinks:load', function(e){

  if(!(['inpatient_prescriptions'].includes(_PAGE.controller) && (['delivery', 'set_products'].includes(_PAGE.action))) ) return false;
  
  $('.inpatient-order-product-cocoon-container').find('tr').each((index, element) => {
    initEvents(element);
  });
  
  $('.inpatient-order-product-cocoon-container').on('cocoon:after-insert', function(e, inserted_item) {
    initEvents(inserted_item);
    $(inserted_item).find('input[name="product_code_fake"]').first().trigger('focus');
    const mainTd = $(inserted_item).closest('td');
    if(!$(mainTd).is(":visible")) $(mainTd).fadeIn();

    $(inserted_item).find('.form-control').each(function(i, element){
      const currentName = $(element).attr('name');
      $(element).attr('name', "ip_products["+Date.now()+"]["+currentName+"]");
    });
    $('[data-toggle="tooltip"]').tooltip({
      'selector': '',
      'container':'body'
    });
  }).on('cocoon:before-remove', function(e, task) {
    // allow some time for the animation to complete
    const table = $(task).closest('table');
    if( $(table).find('tbody tr').length <= 1 ){
      $(table).closest('td').fadeOut('slow');
    }
    $(this).data('remove-timeout', 1000);
    task.fadeOut('slow');
  });
  
  function initEvents(target){
    $(target).find('button.btn-ipp-save').on('click', function(e){
      e.stopPropagation();
      updateOrderProduct(e.target);
    });
    lotSelectBtnWithoutStock(target, target);
    
    $(target).find('.product-code').autocomplete({
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
    $(target).find('.product-name').autocomplete({
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
        tr.find("input.dose_quantity").focus(); // changes focus to quantity input
      },
      response: function(event, ui) {
        $(event.target).parent().siblings('.with-loading').first().removeClass('visible');
      }
    });

    initActionsButton(target); // set eventos de los botones de accion
    calcTotalDoseEvent(target);

  }// fin initEvents

  function onChangeOnSelectAutoCProductCode(target, item){
    if(item){
      const tr = $(target).closest(".nested-fields");
      tr.find("input.product-name").val(item.name); // update product name input
      tr.find("input.product-unity").val(item.unity); // update product unity input      
      tr.find("input.product-stock").val(item.stock); // update product stock input
      tr.find("input.product-id").val(item.id); // update product id input  
      tr.find("input.dose_quantity").first().focus();
    }
  }

  function onSelectAutoCSupplyName(target, item){
    if(item){
      const tr = $(target).closest(".nested-fields");
      tr.find("input.product-code").val(item.code); // update product name input
      tr.find("input.product-unity").val(item.unity); // update product unity input
      tr.find("input.product-stock").val(item.stock); // update product stock input
      tr.find("input.product-id").val(item.id); // update product id input
      tr.find('div.lot-stocks-hidden').html('');
    }
  };
  
  // On change delivery quantity
  function calcTotalDoseEvent(target){
    /* Request Dose and Interval dose */
    $(target).find('input.dose_quantity , input.interval').on('change', function(e){
      calcTotalDose(target);
    });
  }

  function calcTotalDose(row){
    const totalRequestDose = $(row).find('input.dose_quantity').first().val() || 0;
    const totalIntervalDose = $(row).find('input.interval').first().val() || 0;
    const total = (24 /  totalIntervalDose) * totalRequestDose;
    $(row).find('input.total_dose').first().val(total);
  }

});

function updateOrderProduct(target){
  const url = $(target).attr('data-url');
  const urlType = $(target).attr('data-url-type');
  const tr = $(target).closest('tr');
  const parent_id = $(target).attr('data-parent-id');
  const product_id = $(tr).find('input[type="hidden"].product-id').first().val();
  const dose_quantity = $(tr).find('input.dose_quantity').first().val();
  const interval = $(tr).find('input.interval').first().val();
  const deliver_quantity = $(tr).find('input.deliver_quantity').first().val();
  const total_dose = $(tr).find('input.total_dose').first().val();
  const observation = $(tr).find('textarea.product-observartion').first().val();
  const uniqId = Date.now();
  const trId = parent_id ? "child-"+uniqId : "parent-"+uniqId;
  $(tr).find(".is-invalid").removeClass('is-invalid');
  $(tr).attr('id', trId);
  $.ajax({
    url: url,
    method: urlType,
    dataType: "script",
    data: {
      inpatient_prescription_product: {
        product_id: product_id,
        dose_quantity: dose_quantity,
        interval: interval,
        deliver_quantity: deliver_quantity,
        observation: observation,
        parent_id: parent_id,
        total_dose: total_dose
      },
      tr_id: trId
    }
  });
}

/* Seteo de eventos a los botones de accion */
function initActionsButton(target){
  $(target).find('.delete-product').on('click', function(e) {
    const tr_id = $(target).attr("id");
    const modal = $(e.target).attr('data-target');
    const title = $(e.target).attr('data-title');
    const body = $(e.target).attr('data-body');
    const href = $(e.target).attr('data-href');
  
    $(modal).find('.modal-title').text(title);
    $(modal).find('.modal-body').text(body);
    $(modal).find('.btn[data-method="delete"]').attr('href', href+"?tr_id="+tr_id);
    $(modal).modal('toggle');
  });
  
  /* habilitar edicion */
  $(target).find(".btn-ipp-edit").on('click', function(e){
    const tr = $(e.target).closest('tr');
    $(tr).find(".order-product-inputs").removeAttr("readonly");
    $(tr).find(".saved-btn-combo").fadeOut(250, function(){
      $(tr).find(".edit-btn-combo").fadeIn();
    });
  });
  
  /* Cancelar edicion */
  $(target).find(".cancel-item").on('click', function(e){
    const tr_id = $(target).attr("id");
    $(target).find(".order-product-inputs").attr("readonly", true);
    $(target).find(".edit-btn-combo").fadeOut(250, function(){
      $(target).find(".saved-btn-combo").fadeIn();
    });
    const url = $(e.target).attr('data-url');
    const urlType = $(e.target).attr('data-url-type');
    $.ajax({
      url: url,
      method: urlType,
      dataType: "script",
      data: {
        tr_id: tr_id
      }
    });
  });
  
  /* Guardar modificaciones */
  $(target).find(".update-item").on('click', function(e){
    updateOrderProduct(e.target)
  });

  // Se renderiza el porcentual del background
  
}

function setLotSelectionProgress(targetRow, selectedQuantity, toDelivery){
  if(selectedQuantity > toDelivery){
    $(targetRow).find('button.btn-select-lot-stock').addClass('btn-outline-danger').removeClass('btn-outline-success btn-outline-primary');
  }else if(selectedQuantity = toDelivery ){
    $(targetRow).find('button.btn-select-lot-stock').addClass('btn-outline-success').removeClass('btn-outline-danger btn-outline-primary');
  }else{
    $(targetRow).find('button.btn-select-lot-stock').addClass('btn-outline-primary').removeClass('btn-outline-danger btn-outline-success');
  }
} 

/* Funcion que se utiliza para mostrar el modal de seleccion de lotes
*  si tiene stock, de lo contrario muestra un popover con el mensaje
*  "no posee stock".
*  Se llama en las acciones de iniciar el formulario, crear y actualizar un proucto.
*/
function lotSelectBtnWithoutStock(row, current_row){
  const stock = $(row).find('input.product-stock').first().val();
  if(stock > 0){
    $(row).find('button.btn-select-lot-stock').first().on('click', function(e) {
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
    }).trigger('click');
  }else{
    $(row).find('button.btn-select-lot-stock').first().popover({
      content: "Este producto no posee stock",
      delay: { "show": 500, "hide": 500 },
      placement: "left",
      trigger: "manual",
      template: '<div class="popover popover-warning border-warning" role="tooltip"><div class="arrow"></div><div class="popover-body text-warning"></div></div>',
    });
    $(row).find('button.btn-select-lot-stock').addClass('btn-outline-warning').removeClass("btn-primary");
    $(row).find('button.btn-select-lot-stock').popover('show');
    setTimeout(function(){
      $(current_row).find('button.btn-select-lot-stock').popover('hide');
      $(current_row).find('button.btn-select-lot-stock').on('click', function(e){
        $(e.target).popover('show');
        setTimeout(function(){
          $(e.target).popover('hide');
        }, 2500);
      })
    }, 2500);
  }
}