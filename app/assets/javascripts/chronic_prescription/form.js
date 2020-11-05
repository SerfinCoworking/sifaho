$(document).on('turbolinks:load', function(e){
  if( _PAGE.controller !== 'chronic_prescriptions' || !(_PAGE.controller === 'chronic_prescriptions' && (_PAGE.action === 'new' || _PAGE.action === 'edit')) ) return false;
  
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

  $('.date-prescribed').datepicker({
    closeText: 'Cerrar',
    prevText: '<Ant',
    nextText: 'Sig>',
    currentText: 'Hoy',
    monthNames: ['Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio', 'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'],
    monthNamesShort: ['Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun', 'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'],
    dayNames: ['Domingo', 'Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado'],
    dayNamesShort: ['Dom', 'Lun', 'Mar', 'Mié', 'Juv', 'Vie', 'Sáb'],
    dayNamesMin: ['Do', 'Lu', 'Ma', 'Mi', 'Ju', 'Vi', 'Sá'],
    weekHeader: 'Sm',
    dateFormat: 'dd/mm/yy',
    firstDay: 1,
    isRTL: false,
    showMonthAfterYear: false,
    yearSuffix: '',
    maxDate: moment().format("DD/MM/YYYY")
  });

  $('.date-prescribed').on('change', function(e) {
    const datePrescribed = moment(e.target.value, "DD/MM/YYYY");
    const duration = $("input[name='duration-treatment']").val();
    const expiryDate = datePrescribed.add(duration, 'month');
    $('#expiry-date').text(expiryDate.format("DD/MM/YYYY"));
    $('input[type="hidden"]#expiry_date').val(expiryDate.format("YYYY-MM-DD"));
  });

  $("input[name='duration-treatment']").on('change', function(e){
    const duration = $(e.target).val();
    const datePrescribed = moment($('#chronic_prescription_date_prescribed').val(), "DD/MM/YYYY");
    const expiryDate = datePrescribed.add(duration, 'month');
    $('#expiry-date').text(expiryDate.format("DD/MM/YYYY"));
    $('input[type="hidden"]#expiry_date').val(expiryDate.format("YYYY-MM-DD"));
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

  $('#patient-dni').autocomplete({
      source: $('#patient-dni').data('autocomplete-source'),
      autoFocus: true,
      minLength: 7,
      messages: {
        noResults: function() {
          $(".ui-menu-item-wrapper").html("No se encontró el paciente");
        }
      },
      search: function( event, ui ) {
        $(event.target).parent().siblings('.with-loading').first().addClass('visible');
      },
      response: function (event, ui) {
        $(event.target).parent().siblings('.with-loading').first().removeClass('visible');
      },
      select:
      function (event, ui) {
        event.preventDefault();
        $("#patient").tooltip('hide');
        $("#patient_id").val(ui.item.id);
        $("#patient-dni").val(ui.item.dni);
        $("#patient-fullname").val(ui.item.fullname);
        const url = $('#patient-dni').attr('data-insurance-url');
        getInsurances(url, ui.item.dni);
      }
    });

    // Función para autocompletar por nombre o apellido de paciente
    $('#patient-fullname').autocomplete({
      source: $('#patient-fullname').data('autocomplete-source'),
      autoFocus: true,
      minLength: 3,
      messages: {
        noResults: function() {
          $(".ui-menu-item-wrapper").html("No se encontró el paciente");
        }
      },
      search: function( event, ui ) {
        $(event.target).parent().siblings('.with-loading').first().addClass('visible');
      },
      response: function (event, ui) {
        $(event.target).parent().siblings('.with-loading').first().removeClass('visible');
        if (!ui.content.length) {
          $("#patient").tooltip({
            placement: 'bottom', trigger: 'manual', title: 'No se encontró el paciente'
          }).tooltip('show');
        }
      },
      select:
        function (event, ui) {
          event.preventDefault();
          $("#patient").tooltip('hide');
          $("#patient_id").val(ui.item.id);
          $("#patient-dni").val(ui.item.dni);
          $("#patient-fullname").val(ui.item.fullname);
          const url = $('#patient-dni').attr('data-insurance-url');
          getInsurances(url, ui.item.dni);
        }
    });

  function getInsurances(url, dni){
    $.ajax({
      url: url + '/' + dni, // Ruta del controlador
      type: 'GET',
      data: {
      },
      dataType: "json",
      error: function (XMLHttpRequest, errorTextStatus, error) {
        console.log("Failed: "+ errorTextStatus+" ;"+error);
      },
      success: function (data) {
        if (!data.length) {
          $('#non-os').toggleClass('invisible', false);
          $('#pat-os').toggleClass('invisible', true);
        } else {
          $("#pat-os-body").html("");
          for (var i in data) {
            var momentDate = moment(data[i].version)
            $("#pat-os-body").append(
              "<tr>" +
              '<td>' + data[i].financiador + '</td>' +
              '<td class="pres-col-pro">' + data[i].codigoFinanciador + '</td>' +
              '<td>' + momentDate.format("DD/MM/YYYY") + '</td>' +
              "</tr>"
            );
          }
          $('#non-os').toggleClass('invisible', true);
          $('#pat-os').toggleClass('invisible', false);
        } // End if
      }// End success
    });// End ajax
  }


  // cocoon init
  $('#original-order-product-cocoon-container').on('cocoon:after-insert', function(e) {
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

});