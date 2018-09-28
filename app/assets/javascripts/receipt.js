$(document).on('turbolinks:load', function() {
  $('.new-expiry-date').datetimepicker({ format: 'DD/MM/YYYY', locale: 'es' });
  // Función para autocompletar nombre de establecimiento
  jQuery(function() {
    var termTemplate = "<span class='ui-autocomplete-term'>%s</span>";
 
    return $('#provider-establishment').autocomplete({
      source: $('#provider-establishment').data('autocomplete-source'),
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
        $("#provider-establishment-id").val(ui.item.id);
        $('#provider-establishment').trigger('change');
        $("#provider-sector").prop('required',true);
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
  $(document).on('change', '#provider-establishment', function() {
    var select = $("#provider-sector");
    select.prop("disabled", false);
    $.ajax({
      url: "/sectors/with_establishment_id", // Ruta del controlador
      type: 'GET',
      data: {
        term: $('#provider-establishment-id').val()
      },
      async: false,
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
      var termTemplate = "<span class='ui-autocomplete-term'>%s</span>";

      return $('.new-supply-code').autocomplete({
        source: $('.new-supply-code').data('autocomplete-source'),
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
          nested_form.find(".new-supply-id").val(ui.item.value);
          nested_form.find(".new-supply-name").val(ui.item.name);
          if(ui.item.expiry){
            nested_form.find(".new-expiry-date").prop( "disabled", false );
            nested_form.find(".new-expiry-date").val('');
          }else{
            nested_form.find(".new-expiry-date").val('No expira');
            nested_form.find(".new-expiry-date").prop( "disabled", true );
          }
          nested_form.find(".new-deliver-quantity").focus();
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
  $(document).on("focus",".new-supply-name", function() {

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
          nested_form.find(".new-supply-id").val(ui.item.id);
          nested_form.find(".new-supply-code").val(ui.item.id);
          if(ui.item.expiry){
            nested_form.find(".new-expiry-date").prop( "disabled", false );
            nested_form.find(".new-expiry-date").val('');
          }else{
            nested_form.find(".new-expiry-date").val('No expira');
            nested_form.find(".new-expiry-date").prop( "disabled", true );
          }
          nested_form.find('.new-deliver-quantity').focus();
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

  $(document).on("focus",".new-supply-lot-code", function() {
    var _this = $(this);
    // Función para autocompletar código de lote
    jQuery(function() {
      var termTemplate = "<span class='ui-autocomplete-term'>%s</span>";
      return $('.new-supply-lot-code').autocomplete({
        source: $('.new-supply-lot-code').data('autocomplete-source'),
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
          nested_form.find(".new-supply-lot-code").val(ui.item.value);
          nested_form.find(".new-laboratory").val(ui.item.lab_name);
          nested_form.find(".new-laboratory-id").val(ui.item.lab_id);
          nested_form.find(".new-supply-lot-id").val(ui.item.id);
          if(ui.item.expiry_date){
            var date = new Date(ui.item.expiry_date);
            nested_form.find(".new-expiry-date").val((date.getMonth() + 1) + '/' + date.getDate() + '/' +  date.getFullYear())
            nested_form.find(".new-expiry-datetime").val(ui.item.expiry_date);
          }
          nested_form.find(".new-laboratory").focus();
        },
        response: function(event, ui) {
          if (!ui.content.length) {
            var nested_form = _this.parents(".nested-fields");
            nested_form.find(".new-supply-lot-code").val($(this).val());
            nested_form.find(".new-supply-lot-code").tooltip({
            placement: 'bottom',trigger: 'manual', title: 'Nuevo lote'}).tooltip('show');
          }
        }
      })
    });
  });

  // Evento del select sector para rellenar hidden id
  $(document).on('focusout', '.new-supply-lot-code', function() {
      $(this).tooltip('hide');
  });//End on change events

  $(document).on("focus",".new-laboratory", function() {
    var _this = $(this);
    jQuery(function() {
      var termTemplate = "<span class='ui-autocomplete-term'>%s</span>";

      return $('.new-laboratory').autocomplete({
        source: $('.new-laboratory').data('autocomplete-source'),
        autoFocus: true,
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
          var nested_form = _this.parents(".nested-fields");
          nested_form.find(".new-laboratory-id").val(ui.item.id);
        }
      })
    });
  });
});