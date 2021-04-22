$(document).on('turbolinks:load', function(e){
  if(!(_PAGE.controller === 'chronic_prescriptions' && (['new', 'edit', 'create', 'update'].includes(_PAGE.action))) ) return false;
  
  showInsurances();

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
    // Dia prescripto
    if(e.target.value !== 'undefined' && e.target.value !== ''){
      const datePrescribed = e.target.value;
      const momentDatePrescribed = moment(datePrescribed, "DD/MM/YYYY").endOf('month');

      const today = moment().startOf('month');
      const treatmentDuration = $("input[name='duration-treatment']").val();
          
      // Seteamos la fecha de expiracion
      const expiryDate = moment(momentDatePrescribed).add(treatmentDuration, 'month');
      $('#expiry-date').text(expiryDate.format("DD/MM/YYYY"));
      $('input[type="hidden"]#expiry_date').val(expiryDate.format("YYYY-MM-DD"));
      
      const remaining_treatment = treatmentDuration - parseInt(today.diff(momentDatePrescribed, 'months')) || 0;
      /* actualiza todos los totales de dosis cargados por cada producto */
      $("#original-order-product-cocoon-container tr").each((index, tr) => {
        const reqByMonth = $(tr).find('.request-quantity').first().val();
        $(tr).find("input.total-quantity-fake").first().val(remaining_treatment * reqByMonth);
        $(tr).find("input[type='hidden'].total-request-quantity").first().val(remaining_treatment * reqByMonth);
      });
    }else{
      $('#expiry-date').text("");
      $('input[type="hidden"]#expiry_date').val("");
    }
  });

  $("input[name='duration-treatment']").on('change', function(e){
    // Dia prescripto
    const datePrescribed = $("input.prescribed-date").first().val();
    const momentDatePrescribed = moment(datePrescribed, "DD/MM/YYYY").endOf('month');

    const today = moment().startOf('month');
    const treatmentDuration = $(e.target).val();
        
    // Seteamos la fecha de expiracion
    const expiryDate = moment(momentDatePrescribed).add(treatmentDuration, 'month');
    $('#expiry-date').text(expiryDate.format("DD/MM/YYYY"));
    $('input[type="hidden"]#expiry_date').val(expiryDate.format("YYYY-MM-DD"));
    
    const remaining_treatment = treatmentDuration - parseInt(today.diff(momentDatePrescribed, 'months')) || 0;
    /* actualiza todos los totales de dosis cargados por cada producto */
    $("#original-order-product-cocoon-container tr").each((index, tr) => {
      const reqByMonth = $(tr).find('.request-quantity').first().val();
      $(tr).find("input.total-quantity-fake").first().val(remaining_treatment * reqByMonth);
      $(tr).find("input[type='hidden'].total-request-quantity").first().val(remaining_treatment * reqByMonth);
    });

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
 
  // cocoon init
  $('#original-order-product-cocoon-container').on('cocoon:after-insert', function(e, inserted_item) {
    initEvents();
    $(inserted_item).find('input.product-code').first().focus();
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
          $(".ui-menu-item-wrapper").html("No se encontró el nombre del insumo");
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

    /* actualizamos el total de dosis que el tratamiento requiere */
    $(".request-quantity").on("change", function(e){
      const datePrescribed =  $("#chronic_prescription_date_prescribed").val();
      const momentDatePrescribed = moment(datePrescribed, "DD/MM/YYYY").endOf('month');
      const today = moment().startOf('month');
      const treatmentDuration = $("input[name='duration-treatment']").val();
      const remaining_treatment = treatmentDuration - parseInt(today.diff(momentDatePrescribed, 'months')) || 0;
      const tr = $(e.target).closest("tr");
      const reqByMonth = $(e.target).val();
      $(tr).find("input.total-quantity-fake").first().val(remaining_treatment * reqByMonth);
      $(tr).find("input[type='hidden'].total-request-quantity").first().val(remaining_treatment * reqByMonth);
    });
  }// initEvents function

  function onChangeOnSelectAutoCProductCode(target, item){
    if(item){
      const tr = $(target).closest(".nested-fields");
      tr.find("input.product-name").val(item.name); // update product name input
      tr.find("input.product-unity").val(item.unity); // update product unity input      
      tr.find("input.stock-quantity").val(item.stock); // update product stock input
      tr.find("input.product-id").val(item.id); // update product id input  
      tr.find("input.deliver-quantity").focus();
    }
  }

  function onSelectAutoCSupplyName(target, item){
    if(item){
      const tr = $(target).closest(".nested-fields");
      tr.find("input.product-code").val(item.code); // update product name input
      tr.find("input.product-unity").val(item.unity); // update product unity input
      tr.find("input.stock-quantity").val(item.stock); // update product stock input
      tr.find("input.product-id").val(item.id); // update product id input
    }
  }

  function showInsurances(){
    const url = $("#patient-name").attr('data-insurance-url');
    const dni = $("#patient-name").attr('data-patient-dni');
    getInsurances(url, dni);
  }

});