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
  var sector_supply_lot_id = nested_form.find('.sector-supply-lot-id').val();

  $.ajax({
    url: "/sector_supply_lots/select_lot?input_id="+input_id+"&supply_id="+supply_id+"&selected_lot_id="+sector_supply_lot_id,
    type: 'GET',
    data: {
      term: nested_form.find('.supply-code').val()
    },
    dataType: "script",
    error: function (XMLHttpRequest, errorTextStatus, error) {
      alert("Failed: " + errorTextStatus + " ;" + error);
    }
  });// End ajax
});// End jquery function

// Función para rellenar el hidden input del lote y modificar el contenido del botón
$(document).on('click', '.modal-clickable-lot', function () {
  hidden_input_id = document.getElementById($(this).closest("tbody").data("hidden-input-id"));
  lot_code = $(this).data("lot-code");
  lot_quantity = $(this).data("lot-quantity");
  
  // Rellena el valor del hidden input id
  hidden_input_id.value = ($(this).data("lot-id"));

  // Rellena el contenido del botón con el lote seleccionado
  btn = $(hidden_input_id).parents(".nested-fields").find(".select-lot-btn");
  btn.html(
    "<i class='fa fa-barcode'></i> "+lot_code+
    " <i class='fa fa-cubes'></i> "+lot_quantity
  );
  btn.removeClass('btn-primary');
  btn.addClass('btn-light');

  $('#dialog').modal('hide');
});