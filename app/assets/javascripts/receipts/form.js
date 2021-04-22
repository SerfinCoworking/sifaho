$(document).on('turbolinks:load', function(e){
  
  if(!(_PAGE.controller === 'receipts' && (['new', 'edit', 'create', 'update'].includes(_PAGE.action))) ) return false;
  initExpiryDateCalendar();
  
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

  $('#provider-sector').selectpicker();
  
  // on change establishment input
  $('#receipt-provider-id').on('change', function(e){
    if(typeof e.target.value === 'undefined' || typeof e.target.value === null || e.target.value.length < 2){
      $('#provider-sector').find('option').remove();
      $('#provider-sector').selectpicker('refresh', {style: 'btn-sm btn-default'});
    }
  });

  // autocomplete establishment input
  $('#receipt-provider-id').autocomplete({
    source: $('#receipt-provider-id').data('autocomplete-source'),
    minLength: 2,
    autoFocus:true,
    messages: {
      noResults: function() {
        $(".ui-menu-item-wrapper").html("No se encontró al médico");
      }
    },
    search: function( event, ui ) {
      $(event.target).parent().siblings('.with-loading').first().addClass('visible');
    },
    select:
    function (event, ui) {
      getSectors(ui.item.id);
    },
    response: function(event, ui) {
      $(event.target).parent().siblings('.with-loading').first().removeClass('visible');
    }
  });

  // ajax, brings sector according with the establishment ID
  function getSectors(establishmentId){
    if(typeof establishmentId !== 'undefined'){ 
      $.ajax({
        url: "/sectores/with_establishment_id", // Ruta del controlador
        method: "GET",
        dataType: "JSON",
        data: { term: establishmentId}
      })
      .done(function( data ) {
        if(data.length){
          $('#provider-sector').removeAttr("disabled");
          $('#provider-sector').find('option').remove();
          $.each(data, function(index, element){
            $('#provider-sector').append('<option value="'+element.id+'">'+ element.label +'</option>');
          });
          $('#provider-sector').selectpicker('refresh', {style: 'btn-sm btn-default'});
        }
      });
    }else{
      $('#provider-sector').find('option').remove();
      $('#provider-sector').selectpicker('refresh', {style: 'btn-sm btn-default'});
    }
  }

  // cocoon init
  $('#receipt-cocoon-container').on('cocoon:after-insert', function(e, inserted_item) {
    initExpiryDateCalendar();
    $(inserted_item).find('input.receipt-product-code').first().focus();
  });
  
  // set expiry date calendar format
  function initExpiryDateCalendar(){
    // aqui se define el formato para el datepicker de la fecha de vencimiento en "solicitar cargar stock"
    $('.receipt-expiry-date-fake').datepicker({
      format: "mm/yyyy",
      language: 'es',
      minViewMode: 1,
      autoclose: true
    });
    
    // date input change 
    $('.receipt-expiry-date-fake').on('change', function(e){
      setExpiryDate(e.target);    
    });
    
    // autocomplete product code input
    $('.receipt-product-code').autocomplete({
      source: $('.receipt-product-code').attr('data-autocomplete-source'),
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
      change: function (event, ui) {      
        onChangeOnSelectAutoCProductCode(event.target, ui.item);
        const tr = $(event.target).closest(".nested-fields");
        tr.find("input.receipt-quantity").focus(); // changes focus to quantity input
      },
      response: function(event, ui) {
        $(event.target).parent().siblings('.with-loading').first().removeClass('visible');
      }
    });

    // Función para autocompletar y buscar el insumo
    $('.receipt-product-name').autocomplete({
      source: $('.receipt-product-name').attr('data-autocomplete-source'),
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
        onSelectAutoCProductName(event.target, ui.item);
        const tr = $(event.target).closest(".nested-fields");
        tr.find("input.receipt-quantity").focus(); // changes focus to quantity input
      },
      response: function(event, ui) {
        $(event.target).parent().siblings('.with-loading').first().removeClass('visible');
      }
    });

    // Función para autocompletar código de lote
    $(".receipt-product-lot-code").on("focus", function(e) {
      const _this = $(e.target);
      jQuery(function() {
        return $('.receipt-product-lot-code').autocomplete({
          source: '/lotes_provincia/search_by_code?product_code='+_this.closest(".nested-fields").find(".receipt-product-code").val(),
          minLength: 1,
          messages: {
            noResults: function(count) {
              $(".ui-menu-item-wrapper").html("Nuevo lote");
            }
          },
          search: function( event, ui ) {
            $(event.target).parent().siblings('.with-loading').first().addClass('visible');
          },
          select: function (event, ui){

            const tr = $(event.target).closest(".nested-fields");
            tr.find("input.receipt-laboratory-name").val(ui.item.lab_name).trigger('change'); // update product name input
            tr.find("input.receipt-laboratory-id").val(ui.item.lab_id).trigger('change'); // update product name input
            if(ui.item.expiry_date){
              const expiry_date = moment(ui.item.expiry_date);
              tr.find("input.receipt-expiry-date-fake").val(expiry_date.format('MM/YY')); // update product name input
              tr.find("input.receipt-expiry-date").val(expiry_date.endOf('month').format("YYYY-MM-DD")); // update product name input
            }
          },
          response: function(event, ui) {
            $(event.target).parent().siblings('.with-loading').first().removeClass('visible');
          }
        });
      });
    });

    $('.receipt-laboratory-name').autocomplete({
      source: $('.receipt-laboratory-name').data('autocomplete-source'),
      autoFocus: true,
      minLength: 2,
      messages: {
        noResults: function(count) {
          $(".ui-menu-item-wrapper").html("No se encontró el laboratorio");
        }
      },
      search: function( event, ui ) {
        $(event.target).parent().siblings('.with-loading').first().addClass('visible');
      },
      select:
      function (event, ui) {
        const tr = $(event.target).closest(".nested-fields");
        tr.find("input.receipt-laboratory-id").val(ui.item.id).trigger('change'); // update product name input
      },
      response: function(event, ui) {
        $(event.target).parent().siblings('.with-loading').first().removeClass('visible');
      }
    });

  } // end initial function

  function setExpiryDate(target){
    const expireDate = moment($(target).val(), "MM/YYYY").endOf('month');
    const inputHidden = $(target).closest("td").find('.hidden.receipt_receipt_products_expiry_date input[type="hidden"]');
    $(inputHidden).val(expireDate.endOf('month').format("YYYY-MM-DD")); 
  }  

  function onChangeOnSelectAutoCProductCode(target, item){
    if(item){
      const tr = $(target).closest(".nested-fields");
      tr.find("input.receipt-product-name").val(item.name); // update product name input
      tr.find("input.receipt-unity").val(item.unity); // update product unity input      
      tr.find("input.receipt-product-id[type='hidden']").val(item.id); // update product id input      
    }
  }
  
  function onSelectAutoCProductName(target, item){
    if(item){
      const tr = $(target).closest(".nested-fields");
      tr.find("input.receipt-product-code").val(item.code); // update product code input
      tr.find("input.receipt-unity").val(item.unity); // update product unity input
      tr.find("input.receipt-product-id[type='hidden']").val(item.id); // update product id input      
    }
  }

});