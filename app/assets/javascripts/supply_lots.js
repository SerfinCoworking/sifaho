$(document).on('turbolinks:load', function() {
  $('#supply_lot_date_received').datetimepicker({ format: 'DD/MM/YYYY' });
  $('#supply_lot_expiry_date').datetimepicker({ format: 'DD/MM/YYYY' });

  $("#new_supply_lot").bind("ajax:complete", function(event,xhr,status){
    document.getElementById("new_supply_lot").reset();
    $('#supply_lot_supply_id').focus()
  });

  jQuery(function() {
    var termTemplate = "<span class='ui-autocomplete-term'>%s</span>";

    return $('#supply_lot_supply_id').autocomplete({
      source: $('#supply_lot_supply_id').data('autocomplete-source'),
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
        $("#nom_ins").val(ui.item.name);
        $("#supply_id").val(ui.item.value);
        if(ui.item.expiry){
          document.getElementById("supply_lot_expiry_date").disabled = false;
        }else{
          document.getElementById("supply_lot_expiry_date").disabled = true;
        }
      }
    }).each(function() {
        $(this).autocomplete("widget").insertAfter($("#dialog").parent());
    })
  });

  jQuery(function() {
    var termTemplate = "<span class='ui-autocomplete-term'>%s</span>";

    return $('#nom_ins').autocomplete({
      source: $('#nom_ins').data('autocomplete-source'),
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
        $("#supply_lot_supply_id").val(ui.item.id);
        $("#supply_id").val(ui.item.id);
        if(ui.item.expiry){
          document.getElementById("supply_lot_expiry_date").disabled = false;
        }else{
          document.getElementById("supply_lot_expiry_date").disabled = true;
        }
      }
    }).each(function() {
        $(this).autocomplete("widget").insertAfter($("#dialog").parent());
    })
  });

});
