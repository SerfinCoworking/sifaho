$(document).on('turbolinks:load', function() {
  $('#date-received').datetimepicker({ format: 'DD/MM/YYYY' });
  $('#expiry-date').datetimepicker({ format: 'DD/MM/YYYY' });

  $("#expiry-date").on("dp.change", function (e) {
    var date = new Date(e.date);
    $("#sector_supply_lot_expiry_date").val( date.getDate() + '/' + (date.getMonth() + 1) + '/' +  date.getFullYear());
    // $('#sector_supply_lot_expiry_date').data("DateTimePicker").date(e.date);
  });

  $("#new_sector_supply_lot").bind("ajax:complete", function(event,xhr,status){
    document.getElementById("new_sector_supply_lot").reset();
    $("#supply-name").prop( "disabled", false );
    $("#supply-code").prop( "disabled", false );
    $("#expiry-date").prop( "disabled", false );
    $('#supply-code').focus();
  });


  // Función para autocompletar código de insumo
  jQuery(function() {
    var termTemplate = "<span class='ui-autocomplete-term'>%s</span>";

    return $('#supply-code').autocomplete({
      source: $('#supply-code').data('autocomplete-source'),
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
        $("#sector_supply_lot_supply_id").val(ui.item.value);
        $("#supply-name").val(ui.item.name);
        if(ui.item.expiry){
          $("#expiry-date").prop( "disabled", false );
          $("#expiry-date").val('');
        }else{
          $("#expiry-date").val('No expira');
          $("#expiry-date").prop( "disabled", true );
        }
        $("#supply-quantity").focus();
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

  // Función para autocompletar nombre de insumo
  jQuery(function() {
    var termTemplate = "<span class='ui-autocomplete-term'>%s</span>";

    return $('#supply-name').autocomplete({
      source: $('#supply-name').data('autocomplete-source'),
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
        $("#sector_supply_lot_supply_id").val(ui.item.id);
        $("#supply-code").val(ui.item.id);

        if(ui.item.expiry){
          $("#expiry-date").prop( "disabled", false );
          $("#expiry-date").val('');
        }else{
          $("#expiry-date").val('No expira');
          $("#expiry-date").prop( "disabled", true );
        }
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

  // Función para autocompletar código de lote
  jQuery(function() {
    var termTemplate = "<span class='ui-autocomplete-term'>%s</span>";
    return $('#supply-lot-code').autocomplete({
      source: $('#supply-lot-code').data('autocomplete-source'),
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
        $("#sector_supply_lot_lot_code").val(ui.item.value);
        $("#laboratory-lot").val(ui.item.lab_name);
        $("#sector_supply_lot_laboratory_id").val(ui.item.lab_id);
        if(ui.item.expiry_date){
          var date = new Date(ui.item.expiry_date);
          $("#expiry-date").val((date.getMonth() + 1) + '/' + date.getDate() + '/' +  date.getFullYear())
          $("#sector_supply_lot_expiry_date").val(ui.item.expiry_date);
        }
        $("#laboratory-lot").focus();
      },
      response: function(event, ui) {
        if (!ui.content.length) {
          var noResult = { value:"",label:"Nuevo lote" };
          ui.content.push(noResult);
        }
      }
    }).each(function() {
        $(this).autocomplete("widget").insertAfter($("#dialog").parent());
    })
  });

  jQuery(function() {
    var termTemplate = "<span class='ui-autocomplete-term'>%s</span>";

    return $('#laboratory-lot').autocomplete({
      source: $('#laboratory-lot').data('autocomplete-source'),
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
        $("#sector_supply_lot_laboratory_id").val(ui.item.id);
        $("#supply-name").prop( "disabled", false );
        $("#supply-code").prop( "disabled", false );
        $("#expiry-date").prop( "disabled", false );
      }
    }).each(function() {
        $(this).autocomplete("widget").insertAfter($("#dialog").parent());
    })
  });
});
