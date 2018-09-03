$(document).on('turbolinks:load', function() {
  var today = new moment();
  $('#requested-date').datetimepicker({
    format: 'DD/MM/YYYY',
    date: today
  });

  $("#establishment").on("click", function () {
     $(this).select();
  });

  $("#establishment").trigger("change");

  $('.selectpicker').selectpicker(); // Se inicializa selectpicker

  $('.quantity_ord_supply_lots').on('cocoon:after-insert', function(e, insertedItem) {
    $('.selectpicker').selectpicker(); // Se inicializa selectpicker luego de agregar form
  });

  // Función para autocompletar nombre de doctor establecimiento
  jQuery(function() {
   var termTemplate = "<span class='ui-autocomplete-term'>%s</span>";

   return $('#establishment').autocomplete({
     source: $('#establishment').data('autocomplete-source'),
     minLength: 2,
     open: function (e, ui) {
       var acData = $(this).data('ui-autocomplete');
       acData
       .menu
       .element
       .find('li')
       .each(function () {
           var me = $(this);
           var keywords = acData.term.split(' ').join('|');
           me.html(me.text().replace(new RegExp("(" + keywords + ")", "gi"), '<b><u>$1</u></b>'));
       });
     },
     select:
     function (event, ui) {
       $("#establishment-id").val(ui.item.id);
       $('#applicant-sector').prop("disabled", false).selectpicker('refresh');
       $('#applicant-sector').focus();
     },
     response: function(event, ui) {
       if (!ui.content.length) {
           var noResult = { value:"",label:"No se encontró el establecimiento" };
           ui.content.push(noResult);
       }
     }
   })
  });

  // Se completa el select con los sectores asociados al establecimiento
  $(document).on('change', '#establishment', function() {
   var select = $("#applicant-sector");
   select.prop("disabled", false);
   $.ajax({
     url: "/sectors/with_establishment_id", // Ruta del controlador
     type: 'GET',
     data: {
       term: $('#establishment-id').val()
     },
     async: false,
     dataType: "json",
     error: function(XMLHttpRequest, errorTextStatus, error){
       alert("Failed: No se encontraron sectores"+ errorTextStatus+" ;"+error);
     },
     success: function(data){
       if (!data.length) {
         select.selectpicker({title: 'No tiene sectores'}).selectpicker('render');
         $("#applicant-id").val('');
         html = '';
         select.html(html);
         select.selectpicker("refresh");
         select.prop("disabled", true).selectpicker('refresh');
       }else{
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
   $(document).on('change', '#applicant-sector', function() {
     $("#applicant-id").val($(this).val());
   });//End on change events

  // Función para autocompletar y buscar el insumo por código
  $(document).on("focus",".supply-code", function() {
   var _this = $(this);
   jQuery(function() {
     var termTemplate = "<span class='ui-autocomplete-term'>%s</span>";

     return _this.autocomplete({
       source: _this.data('autocomplete-source'),
       autoFocus: true,
       minLength: 1,
       open: function (e, ui) {
         var acData = $(this).data('ui-autocomplete');
         acData
         .menu
         .element
         .find('li')
         .each(function () {
             var me = $(this);
             var keywords = acData.term.split(' ').join('|');
             me.html(me.text().replace(new RegExp("(" + keywords + ")", "gi"), '<b><u>$1</u></b>'));
         });
       },
       select:
       function (event, ui) {
         var nested_form = _this.parents(".nested-fields");
         nested_form.find(".supply-id").val(ui.item.value);
         nested_form.find(".supply-name").val(ui.item.name);
         nested_form.find('.selectpicker').prop("disabled", false).selectpicker('refresh');
         nested_form.find(".request-quantity").prop('disabled', false);
         nested_form.find('.request-quantity').focus();
       },
       response: function(event, ui) {
         if (!ui.content.length) {
             var noResult = { value:"",label:"No se encontró el insumo" };
             ui.content.push(noResult);
         }
       }
     }).each(function() {
         $(this).autocomplete("widget").insertAfter($("#dialog").parent());
     })
   });
  });

  // Función para autocompletar y buscar el insumo
  $(document).on("focus",".supply-name", function() {

   var _this = $(this);

   jQuery(function() {
     var termTemplate = "<span class='ui-autocomplete-term'>%s</span>";

     return _this.autocomplete({
       source: _this.data('autocomplete-source'),
       autoFocus: true,
       minLength: 3,
       open: function (e, ui) {
         var acData = $(this).data('ui-autocomplete');
         acData
         .menu
         .element
         .find('li')
         .each(function () {
             var me = $(this);
             var keywords = acData.term.split(' ').join('|');
             me.html(me.text().replace(new RegExp("(" + keywords + ")", "gi"), '<b><u>$1</u></b>'));
         });
       },
       select:
       function (event, ui) {
         var nested_form = _this.parents(".nested-fields");
         nested_form.find(".supply-id").val(ui.item.id);
         nested_form.find(".supply-code").val(ui.item.id);
         nested_form.find('.selectpicker').prop("disabled", false).selectpicker('refresh');
         nested_form.find(".request-quantity").prop('disabled', false);
         nested_form.find('.request-quantity').focus();
       },
       response: function(event, ui) {
         if (!ui.content.length) {
             var noResult = { value:"",label:"No se encontró el insumo" };
             ui.content.push(noResult);
         }
       }
     }).each(function() {
         $(this).autocomplete("widget").insertAfter($("#dialog").parent());
     })
   });
  });

  $(document).on("keyup change",".request-quantity", function() {
    var _this = $(this);
    jQuery(function() {
      var nested_form = _this.parents(".nested-fields");
      nested_form.find(".deliver-quantity").prop("disabled", false).val(_this.val());
    });
  });

  // Select del lote
  $(document).on('change', '.select-change', function() {
    var nested_form = $(this).parents(".nested-fields");
    var select = nested_form.find('.selectpicker');
    $.ajax({
      url: "/sector_supply_lots/search_by_code", // Ruta del controlador
      type: 'GET',
      data: {
        term: nested_form.find('.supply-code').val()
      },
      async: false,
      dataType: "json",
      error: function(XMLHttpRequest, errorTextStatus, error){
        alert("Failed: "+ errorTextStatus+" ;"+error);
      },
      success: function(data){
        select.empty().selectpicker('refresh'); // Se vacía el select
        if (!data.length) {
          select.selectpicker({title: 'No hay stock'}).selectpicker('render');
          nested_form.find('.supply-lot-laboratory').val('');
          nested_form.find('.supply-lot-expiry').val('');
          html = '';
          select.html(html);
          select.selectpicker("refresh");
          select.prop("disabled", true).selectpicker('refresh');
        }else{
          // Se itera el json
          for(var i in data)
          {
            var id = data[i].id;
            if (data[i].expiry_date) {
              var expiry = new Date(data[i].expiry_date); // Se guarda la fecha de expiración
              var date =   expiry.getDate() + '/'+ (expiry.getMonth() + 1) + '/' +  expiry.getFullYear(); // Se da formato a la fecha
            }else {
              var date = "No expira"
            }
            select.append('<option data-subtext="'+data[i].lab+' '+date+'" \
            class="bg-'+data[i].status_label+'"  data-lab="'+data[i].lab+'" \
            data-quant="'+data[i].quant+'" data-expiry="'+data[i].expiry_date+'" \
            value="'+id+'">'+data[i].lot_code+'</option>');

            if (i == 0) {
                nested_form.find('.supply-lot-expiry').val(date);
            }
          }
          nested_form.find('.supply-lot-laboratory').val(data[0].lab);
          nested_form.find('.deliver-quantity').attr({ "max" : data[0].quant });
          nested_form.find('.supply-lot-id').val(data[0].id);
          select.selectpicker('val', data[0].id);
          select.selectpicker('refresh');
        } // End if
      }// End success
    });// End ajax
  });// End jquery function

  // Evento del código de lote para rellenar otros campos
  $(document).on('change', '.selectpicker', function() {
    var nested_form = $(this).parents(".nested-fields");
    var quant = $('select.selectpicker option[value="' + $(this).val() + '"]').data('quant');
    var expiry = new Date( $('select.selectpicker option[value="' + $(this).val() + '"]').data('expiry') );
    var formatDate = expiry.getDate() + '/'+ (expiry.getMonth() + 1) + '/' +  expiry.getFullYear();
    var lab = $('select.selectpicker option[value="' + $(this).val() + '"]').data('lab');

    nested_form.find('.deliver-quantity').attr({ "max" : quant });
    nested_form.find('.supply-lot-expiry').val(formatDate);
    nested_form.find('.supply-lot-laboratory').val(lab);
    nested_form.find(".supply-lot-id").val($(this).val());
  });//End on change event

  // Return confirmation modal
  $('#return-confirm').on('show', function() {
    var $submit = $(this).find('.btn-warning'),
    href = $submit.attr('href');
    $submit.attr('href', href.replace('pony', $(this).data('id')));
  });

  $('.return-confirm').click(function(e) {
    e.preventDefault();
    $('#return-confirm').data('id', $(this).data('id')).modal('show');
  });
});// End turbolinks load
