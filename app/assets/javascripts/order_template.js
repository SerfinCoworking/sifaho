// Función para autocompletar y buscar el insumo por código
$(document).on("focus",".supply-code-template", function() {
  var _this = $(this);
  jQuery(function() {
    return _this.autocomplete({
      source: _this.data('autocomplete-source'),
      autoFocus: true,
      minLength: 1,
      messages: {
        noResults: function() {
          $(".ui-menu-item-wrapper").html("No se encontró");
        }
      },
      focus: function( event, ui ) {
        var nested_form = _this.parents(".nested-fields");
        nested_form.find(".supply-id").val(ui.item.value);
        nested_form.find(".supply-name-template").val(ui.item.name);
        nested_form.find(".unity").val(ui.item.unity);
        nested_form.find(".area").val(ui.item.supply_area);
        return false;
      },
      select: function (event, ui) {
        var nested_form = _this.parents(".nested-fields");
        nested_form.find(".supply-id").val(ui.item.value);
        nested_form.find(".supply-name-template").val(ui.item.name);
        nested_form.find(".unity").val(ui.item.unity);
        nested_form.find('.focus-quantity').focus();
        if (event.keyCode == 9) {
          nested_form.find(".supply-name").focus();
        }
      }
    });
  });
});


// Función para autocompletar y buscar el insumo
$(document).on("focus",".supply-name-template", function() {

  var _this = $(this);

  jQuery(function() {
    return _this.autocomplete({
      source: _this.data('autocomplete-source'),
      autoFocus: true,
      minLength: 3,
      messages: {
        noResults: function() {
          $(".ui-menu-item-wrapper").html("No se encontró el producto");
        }
      },
      select: function (event, ui) {
        var nested_form = _this.parents(".nested-fields");
        nested_form.find(".supply-id").val(ui.item.id);
        nested_form.find(".supply-code-template").val(ui.item.id);
        nested_form.find(".unity").val(ui.item.unity);
        nested_form.find(".area").val(ui.item.supply_area);
      }
    });
  });
});