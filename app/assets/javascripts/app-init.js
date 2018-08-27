$(document).on('turbolinks:load', function() {
  $.fn.bootstrapSwitch.defaults.onColor = 'success';
  $.fn.bootstrapSwitch.defaults.offColor = 'danger';

  window.setTimeout(function() {
      $(".alert").fadeTo(500, 0).slideUp(500, function(){
          $(this).remove();
      });
  }, 5000);

  $('[data-toggle="tooltip"]').tooltip({delay: { "show": 700, "hide": 100 }});

  $('.datetimepicker').datetimepicker({format: 'DD/MM/YYYY'});

  $('.selectpicker').selectpicker();

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
  }else if ( $(".active").is("#efectores-li") ){
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

  $("#efectores").on("hide.bs.collapse", function(){
    $("#efectores-label").html('<span class="glyphicon glyphicon-chevron-down"></span> <strong>Efectores</strong>');
  });
  $("#efectores").on("show.bs.collapse", function(){
    $("#efectores-label").html('<span class="glyphicon glyphicon-user"></span> <strong>Efectores</strong>');
  });
});
