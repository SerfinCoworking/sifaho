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
    $('#supply-lot-code').focus();
  });

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
        $("#supply-name").val(ui.item.name).prop( "disabled", true );
        $("#supply-lot-code").val(ui.item.id);
        $("#supply-code").val(ui.item.code).prop( "disabled", true );
        $("#sector_supply_lot_supply_id").val(ui.item.supply_id);
        $("#sector_supply_lot_lot_code").val(ui.item.label);
        $("#expiry-date").prop( "disabled", true );
        if(ui.item.expiry_date){
          var date = new Date(ui.item.expiry_date);
          $("#expiry-date").val((date.getMonth() + 1) + '/' + date.getDate() + '/' +  date.getFullYear()).prop( "disabled", true );
          $("#sector_supply_lot_expiry_date").val(ui.item.expiry_date);
        }
        $("#supply-quantity").focus();
      },
      response: function(event, ui) {
        if (!ui.content.length) {
            var noResult = { value:"",label:"Nuevo lote" };
            $("#supply-name").val('').prop( "disabled", false );
            $("#supply-lot-id").val('').prop( "disabled", false );
            $("#supply-code").val('').prop( "disabled", false );
            $("#expiry-date").val('').prop( "disabled", false );
            $("#sector_supply_lot_expiry_date").val('');
            $("#sector_supply_lot_supply_id").val('');
            $("#sector_supply_lot_lot_code").val($(this).val());
            ui.content.push(noResult);
        }
      }
    }).each(function() {
        $(this).autocomplete("widget").insertAfter($("#dialog").parent());
    })
  });

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
});
