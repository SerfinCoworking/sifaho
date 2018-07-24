$(document).on('turbolinks:load', function() {
  window.setTimeout(function() {
      $(".alert").fadeTo(500, 0).slideUp(500, function(){
          $(this).remove();
      });
  }, 2000);

  $('[data-toggle="tooltip"]').tooltip({delay: { "show": 700, "hide": 100 }});

  $('#datetimepicker').datetimepicker({format: 'DD/MM/YYYY HH:mm'});

  var sidebar = document.getElementById('custom-sidebar');
  var page_header = document.getElementById('page-header');
  // Se cambia el color de la sombra del menú lateral
  if( $(".active").is("#pedidos-li") ) {
    sidebar.style.boxShadow = "8px 0 3px 5px #59457c";
    page_header.style.background = "#59457c";
    page_header.style.borderColor = "#59457c";
  }else if ( $(".active").is("#stock-li") ) {
    sidebar.style.boxShadow = "8px 0 3px 5px #10675f";
    page_header.style.background = "#10675f";
    page_header.style.borderColor = "#10675f";
  }else if ( $(".active").is("#usuarios-li") ){
    sidebar.style.boxShadow = "8px 0 3px 5px #89726a";
    page_header.style.background = "#89726a";
    page_header.style.borderColor = "#89726a";
  }else {
    sidebar.style.boxShadow = "8px 0 3px 5px #7c9ed4";
    page_header.style.background = "#7c9ed4";
    page_header.style.borderColor = "#7c9ed4";
  }

  $("#pedidos").on("hide.bs.collapse", function(){
    $("#pedidos-label").html('<span class="glyphicon glyphicon-chevron-down"></span> <strong>Pedidos</strong>');
  });
  $("#pedidos").on("show.bs.collapse", function(){
    $("#pedidos-label").html('<span class="glyphicon glyphicon-list-alt"></span> <strong>Pedidos</strong>');
  });

  $("#stock").on("hide.bs.collapse", function(){
    $("#stock-label").html('<span class="glyphicon glyphicon-chevron-down"></span> <strong>Stock</strong>');
  });
  $("#stock").on("show.bs.collapse", function(){
    $("#stock-label").html('<span class="glyphicon glyphicon-barcode"></span> <strong>Stock</strong>');
  });

  $("#usuarios").on("hide.bs.collapse", function(){
    $("#usuarios-label").html('<span class="glyphicon glyphicon-chevron-down"></span> <strong>Usuarios</strong>');
  });
  $("#usuarios").on("show.bs.collapse", function(){
    $("#usuarios-label").html('<span class="glyphicon glyphicon-user"></span> <strong>Usuarios</strong>');
  });

  $('#dialog').on('shown.bs.modal', function(e) {
  var idNum, supply_lots;
  // Id del form anidado para quantity_supply_lots
  supply_lots = $('#quantity-supply_lots');
  // Métodos para conocer la cantitdad de forms anidados
  idNum = function() {
    return supply_lots.find('.nested-fields').size();
  };
  supply_lots.on('cocoon:before-insert', function(e, el_to_add) {
    return el_to_add.fadeIn(200); // Efecto para el insert
  });
  supply_lots.on('cocoon:after-insert', function(e, added_el) {
    var i, j, ref, results, selectedValue, x;
    // Se coloca el id de los campos anidados
    added_el.find('select').attr("id", "chosen-supply-lot-" + idNum());
    added_el.find('input.form-control.numeric').attr("id", "quantity-supply-lot-" + idNum());
    results = [];
    for (i = j = 1, ref = idNum(); (1 <= ref ? j <= ref : j >= ref); i = 1 <= ref ? ++j : --j) {
      selectedValue = $("#chosen-supply-lot-" + i + " option:selected").val();
      results.push((function() {
        var k, ref1, results1;
        results1 = [];
        for (x = k = 1, ref1 = idNum(); (1 <= ref1 ? k <= ref1 : k >= ref1); x = 1 <= ref1 ? ++k : --k) {
          if (x !== i) {
            $("#chosen-supply-lot-" + x).find('option[value="' + selectedValue + '"]:not(:selected)').attr('disabled', 'disabled');
            results1.push($("#chosen-supply-lot-" + x).trigger("chosen:updated"));
          } else {
            results1.push(void 0);
          }
        }
        return results1;
      })());
    }
    return results;
  });
  supply_lots.on('cocoon:before-remove', function(e, el_to_remove) {
    $(this).data('remove-timeout', 200); // Efecto para remover
    return el_to_remove.fadeOut(200);
  });
  return supply_lots.on('cocoon:after-remove', function(e, removed_el) {});
});

});
