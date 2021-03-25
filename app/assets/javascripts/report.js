$(document).on('turbolinks:load', function() {
  $(document).on('change', '#report-select', function(e){
    var showInput = $('option:selected', this).attr("data-show"); 
    console.log("Data attribute: "+showInput);
    jQuery(function() {
      if ( showInput == "establishment" ){
        $(document).find(".establishment").css('display', 'block');
      }else{
        $(document).find(".establishment").css('display', 'none');
      }
    });
  });

  // mostramos selector test realizado, si el valor seleccionado no es "sospechoso"
  $("#report-consumption-select").on('change', function(e){     
    if($(this).val() === 'por_rubro'){
      $(this).closest('.nested-fields').first().find('.report-area').first().addClass("show");
      $(this).closest('.nested-fields').first().find('.report-product').first().removeClass("show");
    }else{
      $(this).closest('.nested-fields').first().find('.report-product').first().addClass("show");
      $(this).closest('.nested-fields').first().find('.report-area').first().removeClass("show");
    }
  });

});

// Función para autocompletar y buscar el producto por código
$(document).on("focus",".report-product-code", function() {
  var _this = $(this);
  jQuery(function() {

    return _this.autocomplete({
      source: _this.data('autocomplete-source'),
      autoFocus: true,
      minLength: 1,
      focus: function( event, ui ) {
        $(".report-product-code").val(ui.item.value);
        $(".report-product-id").val(ui.item.id);
        $(".report-product-name").val(ui.item.name);
        return false;
      },
      search: function( event, ui ) {
        $(event.target).parent().siblings('.with-loading').first().addClass('visible');
      },
      select: function (event, ui) {
        var nested_form = _this.parents(".nested-fields");
        nested_form.find(".report-product-id").val(ui.item.id);
        nested_form.find(".product-name").val(ui.item.name);
        if (event.keyCode == 9) {
          nested_form.find(".product-name").focus();
        }
      },
      response: function(event, ui) {
        $(event.target).parent().siblings('.with-loading').first().removeClass('visible');
        if (!ui.content.length) {
            var noResult = { value:"",label:"No se encontró el producto" };
            ui.content.push(noResult);
        }
      }
    })
  });
});

// Función para autocompletar y buscar el producto por nombre
$(document).on("focus",".report-product-name", function() {
  var _this = $(this);
  jQuery(function() {

    return _this.autocomplete({
      source: _this.data('autocomplete-source'),
      autoFocus: true,
      noResults: 'myKewlMessage',
      minLength: 1,
      focus: function( event, ui ) {
        $(".report-product-code").val(ui.item.id);
        return false;
      },
      search: function( event, ui ) {
        $(event.target).parent().siblings('.with-loading').first().addClass('visible');
      },
      select:
      function (event, ui) {
        $(".report-product-id").val(ui.item.id);
        $(".report-product-name").val(ui.item.value);
      },
      response: function(event, ui) {
        $(event.target).parent().siblings('.with-loading').first().removeClass('visible');
        if (!ui.content.length) {
            var noResult = { value:"",label:"No se encontró el producto" };
            ui.content.push(noResult);
        }
      }
    })
  });
});