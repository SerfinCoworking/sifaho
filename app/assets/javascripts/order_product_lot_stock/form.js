$(document).on('turbolinks:load', function(e){
  if(!([
      'establishments/external_orders/applicants',
      'establishments/external_orders/providers', 
      'sectors/internal_orders/applicants',
      'sectors/internal_orders/providers'].includes(_PAGE.controller) && 
      (['new', 'edit', 'accept_order', 'create', 'update', 'dispatch_order', 'edit_products'].includes(_PAGE.action))) ) return false;
  
  initProductsEvents();
  
  // button submit
  $("button.send-order").on('click', function(e){
    e.preventDefault();
    const anyEditingForm = $('#order-products-container').find('form.editing').length;
    const href = $(e.target).attr('data-url');
    if(anyEditingForm){
      // open modal unsaved changes
      const modal = "#send-unsaved-confirmation";
      const title = $(e.target).attr('data-title');
      const body = $(e.target).attr('data-body');

      $(modal).find('.modal-title').text(title);
      $(modal).find('.modal-body').text(body);
      $(modal).find('a#send-confirm-btn').attr('href', href);
      $(modal).modal('toggle');
    }else{
      if($(e.target).hasClass('provider-order')){
        const modal = "#send-confirmation";
        const title = "Enviando provisión de sector";
        const body = "Está seguro de enviar la provisión?";

        $(modal).find('.modal-title').text(title);
        $(modal).find('.modal-body').text(body);
        $(modal).find('a#send-confirm-btn').attr('href', href);
        $(modal).modal('toggle');
      }else{
        window.location.href = href;
      }
    }
  });
  
})
// set expiry date calendar format
function initProductsEvents(){
  // autocomplete establishment input
  $('.product-code').autocomplete({
    source: $('.product-code').last().attr('data-autocomplete-source'),
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

  $('.product-code, .product-id, .product-name, .request-quantity, .observations').on('change', function(e){
    $(e.target).closest('form').addClass('editing');
  });
  
  $(".enable-editing-btn").on('click', function(e){
    e.stopPropagation();
    $(e.target).closest('.col-action-btn').removeClass('hidden-content');
    $(e.target).closest('.nested-fields').find('.product-code, .product-name, .request-quantity, .observations').removeAttr('readonly');
    $(e.target).closest('.enable-editing-buttons').fadeOut(300, function(){
      $(e.target).closest('.enable-editing-buttons').siblings('.editing-buttons').fadeIn(300);
    });
  });

  $('.btn-delete-product').on('click', function(e){
    $(e.target).closest('.row.nested-fields').fadeOut(300, function(){
      $(e.target).closest('form.simple_form').remove();
    });
  });

  $('.btn-delete-confirm').on('click', function(e) {
    const modal = $(e.target).attr('data-target');
    const title = $(e.target).attr('data-title');
    const body = $(e.target).attr('data-body');
    const href = $(e.target).attr('data-href');

    $(modal).find('.modal-title').text(title);
    $(modal).find('.modal-body').text(body);
    $(modal).find('.btn[data-method="delete"]').attr('href', href);
    $(modal).modal('toggle');
  });

}// initProductsEvents function

function onChangeOnSelectAutoCProductCode(target, item){
  if(item){
    const tr = $(target).closest(".nested-fields");
    tr.find("input.product-name").val(item.name); // update product name input
    tr.find("input.product-unity").val(item.unity); // update product unity input      
    tr.find("input.stock-quantity").val(item.stock); // update product stock input
    tr.find("input.product-id").val(item.id); // update product id input  
    tr.find("input.request-quantity").focus();
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
