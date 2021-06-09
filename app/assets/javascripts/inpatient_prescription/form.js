$(document).on('turbolinks:load', function(e){

  if(!(['inpatient_prescriptions'].includes(_PAGE.controller) && (['new', 'edit', 'create', 'update'].includes(_PAGE.action))) ) return false;
  
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

  $('.datepicker').datepicker({
    format: "dd/mm/yyyy",
    language: "es",
    autoclose: true,
    endDate: new Date(),
  });

  $('.prescribed-date').on('change', function(e) {
    setExpirydate(e.target.value);
  });

  // Calculamos el valor de vencimiento de la receta
  function setExpirydate(value){
    if(value !== 'undefined' && value !== ''){
      const datePrescribed = moment(value, "DD/MM/YYYY");
      const expiryDate = datePrescribed.add(3, 'month');
      $('#expiry-date').text(expiryDate.format("DD/MM/YYYY"));
      $('input[type="hidden"]#expiry_date').val(expiryDate.format("YYYY-MM-DD"));
    }else{
      $('#expiry-date').text("");
      $('input[type="hidden"]#expiry_date').val("");
    }      
  }

  // cocoon init
  $('#inpatient-order-product-cocoon-container').on('cocoon:after-insert', function(e, inserted_item) {
    initEvents();
    $(inserted_item).find('input.product-code').first().focus();
  });

  // Función para autocompletar nombre y apellido del doctor
  $('#professional').autocomplete({
    source: $('#professional').data('autocomplete-source'),
    minLength: 2,
    autoFocus:true,
    messages: {
      noResults: function(count) {
        $(".ui-menu-item-wrapper").html("No se encontró al médico");
      }
    },
    search: function( event, ui ) {
      $(event.target).parent().siblings('.with-loading').first().addClass('visible');
    },
    select:
    function (event, ui) {
      $("#professional_id").val(ui.item.id);
    },
    response: function(event, ui) {
      $(event.target).parent().siblings('.with-loading').first().removeClass('visible');
    }
  });
  
  // set expiry date calendar format
  function initEvents(){
    
    // autocomplete codigo de producto
    $('.product-code').on('keydown', function(e){
      e.stopPropagation();
    
      $(e.target).autocomplete({
        source: $(e.target).attr('data-autocomplete-source'),
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
    });

    $('.product-name').on('keydown', function(e){
      // Función para autocompletar y buscar el insumo
      $(e.target).autocomplete({
        source: $(e.target).attr('data-autocomplete-source'),
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
    });
    
    calcTotalDoseEvent();
  }// initEvents function

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
  }

  // On change delivery quantity
  function calcTotalDoseEvent(){
    /* Request Dose and Interval dose */
    $('input.request-quantity , input.interval-dose').on('change', function(e){
      const tr = $(e.target).closest(".nested-fields");
      calcTotalDose(tr);
    });
  }

  function calcTotalDose(row){
    const totalRequestDose = $(row).find('input.request-quantity').first().val() || 0;
    const totalIntervalDose = $(row).find('input.interval-dose').first().val() || 0;
    const total = (24 /  totalIntervalDose) * totalRequestDose;
    $(row).find('input.total-dose').first().val(total);
  }
});