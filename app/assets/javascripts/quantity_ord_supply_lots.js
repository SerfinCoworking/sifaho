$(document).on("keyup change",".apply-request-quant", function() {
  var _this = $(this);
  jQuery(function() {
    var nested_form = _this.parents(".nested-fields");
    nested_form.find('.apply-deliver-quant').val(_this.val());
  });
});

// Select del lote
$(document).on('click', '.select-lot-btn', function () {
  var nested_form = $(this).parents(".nested-fields");
  var input_id = nested_form.find('.sector-supply-lot-id').attr("id");
  var supply_id = nested_form.find('.supply-id').val();
  console.log(supply_id);
  var sector_supply_lot_id = nested_form.find('.sector-supply-lot-id').val();
  console.log(sector_supply_lot_id);
  $.ajax({
    url: "/sector_supply_lots/select_lot?input_id="+input_id+"&supply_id="+supply_id+"&selected_lot_id="+sector_supply_lot_id, // Ruta del controlador
    type: 'GET',
    data: {
      term: nested_form.find('.supply-code').val()
    },
    dataType: "script",
    error: function (XMLHttpRequest, errorTextStatus, error) {
      alert("Failed: " + errorTextStatus + " ;" + error);
    },
    success: function (data) {
    }// End success
  });// End ajax
});// End jquery function

