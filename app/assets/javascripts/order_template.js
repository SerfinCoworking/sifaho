// Función para autocompletar y buscar el insumo por código
$(document).on("focus",".supply-code-template", function() {
  var _this = $(this);
  jQuery(function() {
    var termTemplate = "<span class='ui-autocomplete-term'>%s</span>";

    return _this.autocomplete({
      source: _this.data('autocomplete-source'),
      autoFocus: true,
      minLength: 1,
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
      },
      response: function(event, ui) {
        if (!ui.content.length) {
            var noResult = { value:"",label:"No se encontró el insumo" };
            ui.content.push(noResult);
        }
      }
    })
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
      select: function (event, ui) {
        var nested_form = _this.parents(".nested-fields");
        nested_form.find(".supply-id").val(ui.item.id);
        nested_form.find(".supply-code-template").val(ui.item.id);
        nested_form.find(".unity").val(ui.item.unity);
        nested_form.find(".area").val(ui.item.supply_area);
      },
      response: function(event, ui) {
        if (!ui.content.length) {
            var noResult = { value:"",label:"No se encontró el insumo" };
            ui.content.push(noResult);
        }
      }
    })
  });
});