$(document).on('turbolinks:load', function () {
  var today = new moment();
  $('#requested-date').datetimepicker({
    format: 'DD/MM/YYYY',
    date: today,
    locale: 'es'
  });

  // Función para autocompletar nombre de establecimiento
  jQuery(function() {  
    return $('#establishment').autocomplete({
      source: $('#establishment').data('autocomplete-source'),
      minLength: 2,
      messages: {
        noResults: function(count) {
          $(".ui-menu-item-wrapper").html("No se encontró el establecimiento");
        }
      },
      select:
      function (event, ui) {
        $("#establishment-id").val(ui.item.id);
        $('#establishment').trigger('change');
        $("#applicant-sector").prop('required',true);
      }
    })
  });


  $(document).on('cocoon:after-insert', '.quantity_ord_supply_lots', function(e, added_task) {
    added_task.find('.external_order_quantity_ord_supply_lots_expiry_date_fake .input-group.date')
      .datetimepicker({
        format: 'MM/YY',
        viewMode: 'months',
        locale: 'es',
        useCurrent: false,
      });
      $('.external_order_quantity_ord_supply_lots_expiry_date_fake .input-group.date').on('change.datetimepicker', function(e){
        const inputDate = $(e.target).find('input.datetimepicker-input').first().val();
        if(typeof inputDate !== 'undefined'){
          const td = $(e.target).closest('td');
          const expiryDateFormated = moment(inputDate, "MM/YY");
          $(td).find('input.new-expiry-date-hidden').first().val(expiryDateFormated.endOf("month").format("YYYY-MM-DD"));
        }
      });
      
      $('.external_order_quantity_ord_supply_lots_expiry_date_fake .input-group.date input.datetimepicker-input').on('change', function(e){
        $(e.target).parent().trigger('change.datetimepicker');
      });
    $('[data-toggle="tooltip"]').tooltip({ 'selector': '', 'container':'body' });
  });

  $(document).on('cocoon:before-remove', '.quantity_ord_supply_lots', function(e, task) {
    $("[data-toggle='tooltip']").tooltip('hide');
  });

  // Función para autocompletar nombre de establecimiento
  jQuery(function() { 
    return $('#provider-establishment').autocomplete({
      source: $('#provider-establishment').data('autocomplete-source'),
      minLength: 2,
      messages: {
        noResults: function(count) {
          $(".ui-menu-item-wrapper").html("No se encontró el establecimiento");
        }
      },
      select:
      function (event, ui) {
        $("#provider-establishment-id").val(ui.item.id);
        $('#provider-establishment').trigger('change');
        $("#provider-sector").prop('required',true);
      }
    })
   });

  // Se completa el select con los sectores asociados al establecimiento
  $(document).on('change', '#provider-establishment', function() {
    var select = $("#provider-sector");
    select.prop("disabled", false);
    $.ajax({
      url: "/sectors/with_establishment_id", // Ruta del controlador
      type: 'GET',
      data: {
        term: $('#provider-establishment-id').val()
      },
      dataType: "json",
      error: function(XMLHttpRequest, errorTextStatus, error){
        alert("Failed: No se encontraron sectores"+ errorTextStatus+" ;"+error);
      },
      success: function(data){
        if (!data.length) {
          select.selectpicker({title: 'No hay sectores'}).selectpicker('render');
          $("#provider-id").val('');
          html = '';
          select.html(html);
          select.selectpicker("refresh");
        }else{
          select.selectpicker({title: 'Seleccione un sector'}).selectpicker('render');
          html = '';
          select.empty().selectpicker('refresh'); // Se vacía el select
          // Se itera el json
          for(var i in data)
          {
            select.append('<option value="'+data[i].id+'">'+data[i].label+'</option>');
          }
          select.selectpicker('refresh');
        }
      }
    });
   });

  // Evento del select sector para rellenar hidden id
  $(document).on('change', '#provider-sector', function() {
    $("#provider-id").val($(this).val());
  });//End on change events

  // Función para autocompletar código de insumo
  $(document).on("focus",".new-supply-code", function() {
    var _this = $(this);
    jQuery(function() {
      return $('.new-supply-code').autocomplete({
        source: $('.new-supply-code').data('autocomplete-source'),
        autoFocus: true,
        minLength: 1,
        messages: {
          noResults: function(count) {
            $(".ui-menu-item-wrapper").html("No se encontró");
          }
        },
        search: function( event, ui ) {
          $(event.target).parent().siblings('.with-loading').first().addClass('visible');
        },
        focus: function( event, ui ) {
          var nested_form = _this.parents(".nested-fields");
          nested_form.find(".new-supply-id").val(ui.item.value);
          nested_form.find(".new-supply-name").val(ui.item.name);
          nested_form.find(".unity").val(ui.item.unity);
          return false;
        },
        select:
        function (event, ui) {
          var nested_form = _this.parents(".nested-fields");
          nested_form.find(".new-supply-id").val(ui.item.value);
          nested_form.find(".new-supply-name").val(ui.item.name);
          nested_form.find(".new-expiry-date").prop( "disabled", false );
          nested_form.find(".new-expiry-date").val('');
          nested_form.find(".new-deliver-quantity").focus();
          if (event.keyCode == 9) {
            nested_form.find(".new-supply-name").focus();
          }
        },
        response: function(event, ui) {
          $(event.target).parent().siblings('.with-loading').first().removeClass('visible');
        }
      });
    });
  });

  // Función para autocompletar y buscar el insumo
  $(document).on("focus",".new-supply-name", function() {
    var _this = $(this);
    jQuery(function() {  
      return _this.autocomplete({
        source: _this.data('autocomplete-source'),
        autoFocus: true,
        minLength: 3,
        messages: {
          noResults: function(count) {
            $(".ui-menu-item-wrapper").html("No se encontró el producto");
          }
        },
        search: function( event, ui ) {
          $(event.target).parent().siblings('.with-loading').first().addClass('visible');
        },
        select:
        function (event, ui) {
          var nested_form = _this.parents(".nested-fields");
          nested_form.find(".new-supply-id").val(ui.item.id);
          nested_form.find(".new-supply-code").val(ui.item.id);
          nested_form.find(".unity").val(ui.item.unity);
          nested_form.find('.new-deliver-quantity').focus();
        },
        response: function(event, ui) {
          $(event.target).parent().siblings('.with-loading').first().removeClass('visible');
        }
      });
    });
  });

  // Función para autocompletar código de lote
  $(document).on("focus",".new-supply-lot-code", function() {
    var _this = $(this);
    jQuery(function() {
      return $('.new-supply-lot-code').autocomplete({
        source: '/supply_lots/search_by_lot_code?supply_code='+_this.parents(".nested-fields").find(".new-supply-code").val(),
        minLength: 1,
        messages: {
          noResults: function(count) {
            $(".ui-menu-item-wrapper").html("Nuevo lote");
          }
        },
        focus: function( event, ui ) {
          var nested_form = _this.parents(".nested-fields");
          nested_form.find(".new-laboratory").val(ui.item.lab_name);
          return false;
        },
        search: function( event, ui ) {
          $(event.target).parent().siblings('.with-loading').first().addClass('visible');
        },
        select: function (event, ui){
          var nested_form = _this.parents(".nested-fields");
          nested_form.find(".new-supply-lot-code").val(ui.item.value);
          nested_form.find(".new-laboratory").val(ui.item.lab_name);
          nested_form.find(".new-laboratory-id").val(ui.item.lab_id);
          nested_form.find(".new-supply-lot-id").val(ui.item.id);
          if(ui.item.expiry_date){
            const expiryDate = moment(ui.item.expiry_date);
            nested_form.find(".new-expiry-date").val( expiryDate.endOf('month').format("YYYY-MM-DD"));
            nested_form.find(".new-expiry-date-hidden").val(expiryDate.endOf('month').format("YYYY-MM-DD"));
          }
          nested_form.find(".new-laboratory").focus();
        },
        response: function(event, ui) {
          $(event.target).parent().siblings('.with-loading').first().removeClass('visible');
        }
      });
    });
  });

  // Evento del select sector para rellenar hidden id
  $(document).on('focusout', '.new-supply-lot-code', function() {
    $(this).tooltip('hide');
  });//End on change events

  $(document).on("focus",".new-laboratory", function() {
    var _this = $(this);
    jQuery(function() {
      return $('.new-laboratory').autocomplete({
        source: $('.new-laboratory').data('autocomplete-source'),
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
          var nested_form = _this.parents(".nested-fields");
          nested_form.find(".new-laboratory-id").val(ui.item.id);
        },
        response: function(event, ui) {
          $(event.target).parent().siblings('.with-loading').first().removeClass('visible');
        }
      });
    });
  });

  $('.table-responsive').on('show.bs.select', function () { 
    $('.table-responsive').css( "overflow", "inherit" );
    $('.bootstrap-table').css( "overflow", "inherit" ); 
    $('.fixed-table-body').css( "overflow", "inherit" );  
  }); 

  $('.table-responsive').on('hide.bs.select', function () { 
    $('.table-responsive').css( "overflow", "auto" ); 
  });
});

