// Función para autocompletar y buscar el insumo por código
$(document).on("focus",".supply-code", function() {
  var _this = $(this);

  jQuery(function() {
    return _this.autocomplete({
      source: _this.data('autocomplete-source'),
      autoFocus: true,
      minLength: 1,
      messages: {
        noResults: function(count) {
          $(".ui-menu-item-wrapper").html("No se encontró ese producto");
        }
      },
      search: function( event, ui ) {
        $(event.target).parent().siblings('.with-loading').first().addClass('visible');
      },
      focus: function( event, ui ) {
        var nested_form = _this.parents(".nested-fields");
        nested_form.find(".supply-id").val(ui.item.value);
        nested_form.find(".supply-name").val(ui.item.name);
        nested_form.find(".unity").val(ui.item.unity);
        nested_form.find('.sector-supply-lot-id').val('');
        reset_select_lot_btn(nested_form.find(".select-lot-btn"));
        nested_form.find(".request-quantity").prop('disabled', false);
        nested_form.find(".select-change").trigger('change');
        return false;
      },
      select: function (event, ui) {
        var nested_form = _this.parents(".nested-fields");
        nested_form.find(".supply-id").val(ui.item.value);
        nested_form.find(".supply-name").val(ui.item.name);
        nested_form.find(".unity").val(ui.item.unity);
        nested_form.find('.sector-supply-lot-id').val('');
        reset_select_lot_btn(nested_form.find(".select-lot-btn"));
        nested_form.find(".request-quantity").prop('disabled', false);
        nested_form.find(".select-change").trigger('change');
        nested_form.find('.focus-quantity').focus();
        if (event.keyCode == 9) {
          nested_form.find(".supply-name").focus();
        }
      },
      response: function(event, ui) {
        $(event.target).parent().siblings('.with-loading').first().removeClass('visible');
      }
    });
  });
});

// Función para autocompletar y buscar el insumo
$(document).on("focus",".supply-name", function() {
  var _this = $(this);

  jQuery(function() {
    return _this.autocomplete({
      source: _this.data('autocomplete-source'),
      autoFocus: true,
      minLength: 3,
      messages: {
        noResults: function(count) {
          $(".ui-menu-item-wrapper").html("No se encontró ese producto");
        }
      },
      select:
      function (event, ui) {
        var nested_form = _this.parents(".nested-fields");
        nested_form.find(".supply-id").val(ui.item.id);
        nested_form.find(".supply-code").val(ui.item.id);
        nested_form.find('.sector-supply-lot-id').val('');
        reset_select_lot_btn(nested_form.find(".select-lot-btn"));
        nested_form.find(".request-quantity").prop('disabled', false);
        nested_form.find(".select-change").trigger('change');
        nested_form.find('.focus-quantity').focus();
      },
      search: function( event, ui ) {
        $(event.target).parent().siblings('.with-loading').first().addClass('visible');
      },
      response: function(event, ui) {
        $(event.target).parent().siblings('.with-loading').first().removeClass('visible');
      }
    });
  });
});

$(document).on("keyup change",".request-quantity", function() {
  var _this = $(this);
  jQuery(function() {
    var nested_form = _this.parents(".nested-fields");
    nested_form.find('.deliver-quantity').attr({ "max" : _this.val() });
    nested_form.find(".deliver-quantity").prop("disabled", false).val(_this.val());
  });
});

$(document).on('turbolinks:load', function() {
  $('#cocoon-container')
    .on('cocoon:before-insert', function(e,task_to_be_added) {
      task_to_be_added.fadeIn('fast');
    })
    .on("cocoon:before-remove", function() {
    });
});

function reset_select_lot_btn(btn) {
  btn.html("<i class='fa fa-barcode'></i> Seleccionar lote");
  btn.removeClass('btn-light');
  btn.addClass('btn-primary');
}