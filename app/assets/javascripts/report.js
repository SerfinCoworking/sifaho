$(document).on('turbolinks:load', function() {
  $(document).on('change', '#report-select', function(e){
    var showInput = $('option:selected', this).attr("data-show"); 
    console.log("cambió");
    console.log("Data attribute: "+showInput);
    jQuery(function() {
      if ( showInput == "establishment" ){
        console.log("Entró");
        $(document).find(".establishment").css('display', 'block');
      }else{
        $(document).find(".establishment").css('display', 'none');
      }
    });
  });
});

// Función para autocompletar y buscar el insumo por código
$(document).on("focus",".report-supply-code", function() {
  var _this = $(this);
  jQuery(function() {

    return _this.autocomplete({
      source: _this.data('autocomplete-source'),
      autoFocus: true,
      minLength: 1,
      focus: function( event, ui ) {
      $(".report-supply-id").val(ui.item.value);
      $(".report-supply-name").val(ui.item.name);
      return false;
    },
      select:
      function (event, ui) {
      var nested_form = _this.parents(".nested-fields");
      nested_form.find(".supply-id").val(ui.item.value);
      nested_form.find(".supply-name").val(ui.item.name);
      nested_form.find(".unity").val(ui.item.unity);
      nested_form.find('.selectpicker').prop("disabled", false).selectpicker('refresh');
      nested_form.find(".request-quantity").prop('disabled', false);
      nested_form.find(".select-change").trigger('change');
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