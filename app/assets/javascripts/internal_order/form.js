$(document).on('turbolinks:load', function(e){
  if( _PAGE.controller !== 'internal_orders' && (_PAGE.action !== 'new_applicant' || _PAGE.action !== 'edit_applicant') ) return false;
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
  $('#internal-order-product-cocoon-container').on('cocoon:after-insert', function(e) {
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
    $("input.deliver-quantity").on('change', function(e){
      const quantity = $(e.target).val();
      const tr = $(e.target).closest(".nested-fields");
      tr.find("input.request-quantity").val(quantity);
    });

    lotsQuantitySelection();

  }// initEvents function

  function onChangeOnSelectAutoCProductCode(target, item){
    if(item){
      const tr = $(target).closest(".nested-fields");
      tr.find("input.product-name").val(item.name); // update product name input
      tr.find("input.product-unity").val(item.unity); // update product unity input      
      tr.find("input.stock-quantity").val(item.stock); // update product stock input      
      tr.find("input.deliver-quantity").focus();
    }
  }

  function onSelectAutoCSupplyName(target, item){
    if(item){
      const tr = $(target).closest(".nested-fields");
      tr.find("input.product-code").val(item.code); // update product name input
      tr.find("input.product-unity").val(item.unity); // update product unity input
      tr.find("input.stock-quantity").val(item.stock); // update product stock input      
    }
  }

  function lotsQuantitySelection(){
    // Select del lote
    $(".select-lot-btn").on('click', function(e){

      const templateHidden = $(e.target).attr("data-template-fill-hidden");
      const hiddenTarget = $(e.target).attr("data-hidden-target");
      const tr = $(e.target).closest(".nested-fields");
      const url = $(e.target).attr('data-select-lot-url');
      const productCode = tr.find("input.product-code").val(); // update product name input
      const toDelivery = tr.find("input.deliver-quantity").val(); // update product name input
      const selectedLots = $(hiddenTarget).find('.lots');

      if(!productCode){
        $('.modal-header').addClass('bg-warning');
        $('.modal-title').html("<i class='fa fa-exclamation-triangle'></i>  Elegir un producto");
        $('.modal-body').html("<p>No se ha seleccionado ningún producto</p><p>Por favor seleccione uno</p>");
        $('.modal-footer').html(
          "<button type='button' class='btn' data-dismiss='modal'>Volver</button>"
        );
        $('#dialog').modal("show");
        $('#dialog').on('hidden.bs.modal', function () {
          $('.modal-header').removeClass('bg-warning');
        });
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
        $('.modal-dialog').addClass('modal-lg');
        $('.modal-header').addClass('bg-primary text-white');
        $('.modal-title').html("<i class='fa fa-barcode'></i>  Seleccionar lote en stock");
        
        $('.modal-body').html(table_body);

        // Add form button
        $('.modal-footer').html(
          "<button type='button' class='btn' data-dismiss='modal'>Volver</button>"
        );

        // Show the dynamic dialog
        $('#dialog').modal("show");

        // Remove style
        $('#dialog').on('hidden.bs.modal', function (e) {
          $(hiddenTarget).html(''); //clean every input stored
          // handle selected options
          const selectedOptions = $(e.target).find('tr.selected-row');
          selectedOptions.map((index, option) => {
            // option
            addLot(hiddenTarget, templateHidden, option);
          });

          $('.modal-header').removeClass('bg-secondary text-white');
          $('.modal-dialog').removeClass('modal-lg');
        });
      });// End 

    });// End lot selection button click action
  }

});